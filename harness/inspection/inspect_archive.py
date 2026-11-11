#!/usr/bin/env python3
"""Static archive inspection for Nexus Harness. Never extracts or executes files."""
import argparse
import json
import stat
import sys
import tarfile
import zipfile
from pathlib import Path, PurePosixPath

MAX_ENTRIES = 20000
MAX_TOTAL_SIZE = 1024 * 1024 * 1024
MAX_SINGLE_SIZE = 512 * 1024 * 1024
MAX_RATIO = 100


def unsafe_path(name):
    if not isinstance(name, str) or not name or "\x00" in name:
        return True
    normalized = name.replace("\\", "/")
    if normalized.startswith("/") or (len(normalized) >= 2 and normalized[1] == ":"):
        return True
    return any(part == ".." for part in PurePosixPath(normalized).parts)


def inspect_zip(path):
    findings, entries, total = [], 0, 0
    with zipfile.ZipFile(path) as archive:
        infos = archive.infolist()
        if len(infos) > MAX_ENTRIES:
            findings.append("archive exceeds entry-count limit")
        for info in infos[:MAX_ENTRIES]:
            entries += 1
            if unsafe_path(info.filename):
                findings.append("unsafe path: " + info.filename[:160])
            mode = (info.external_attr >> 16) & 0xFFFF
            if stat.S_ISLNK(mode):
                findings.append("symbolic link entry: " + info.filename[:160])
            if info.flag_bits & 0x1:
                findings.append("encrypted entry: " + info.filename[:160])
            if info.file_size > MAX_SINGLE_SIZE:
                findings.append("oversized entry: " + info.filename[:160])
            total += info.file_size
            if info.file_size and info.compress_size == 0:
                findings.append("invalid zero-size compressed stream: " + info.filename[:160])
            elif info.compress_size and info.file_size / info.compress_size > MAX_RATIO:
                findings.append("high compression ratio: " + info.filename[:160])
        if total > MAX_TOTAL_SIZE:
            findings.append("archive exceeds total uncompressed-size limit")
    return entries, total, findings


def inspect_tar(path):
    findings, entries, total = [], 0, 0
    with tarfile.open(path, mode="r:*") as archive:
        for member in archive:
            entries += 1
            if entries > MAX_ENTRIES:
                findings.append("archive exceeds entry-count limit")
                break
            if unsafe_path(member.name):
                findings.append("unsafe path: " + member.name[:160])
            if member.issym() or member.islnk():
                findings.append("link entry: " + member.name[:160])
            if member.isdev() or member.isfifo():
                findings.append("special device entry: " + member.name[:160])
            if member.size < 0 or member.size > MAX_SINGLE_SIZE:
                findings.append("invalid or oversized entry: " + member.name[:160])
            total += max(member.size, 0)
            if total > MAX_TOTAL_SIZE:
                findings.append("archive exceeds total uncompressed-size limit")
                break
    return entries, total, findings


def inspect(path):
    if not path.is_file():
        raise ValueError("input is not a regular file")
    if zipfile.is_zipfile(path):
        entries, total, findings = inspect_zip(path)
        archive_type = "zip"
    elif tarfile.is_tarfile(path):
        entries, total, findings = inspect_tar(path)
        archive_type = "tar"
    else:
        raise ValueError("unsupported or unrecognized archive format")
    return {
        "file": path.name,
        "format": archive_type,
        "entries_scanned": entries,
        "declared_uncompressed_bytes": total,
        "decision": "REVIEW_REQUIRED" if findings else "NO_STATIC_RED_FLAGS",
        "findings": findings,
        "execution_performed": False,
        "extraction_performed": False,
        "warning": "Static inspection is not malware detection or proof of safety."
    }


def main():
    parser = argparse.ArgumentParser(description="Inspect ZIP/TAR metadata without extracting or executing it.")
    parser.add_argument("archive", type=Path)
    parser.add_argument("--json", action="store_true", help="emit machine-readable JSON")
    args = parser.parse_args()
    try:
        report = inspect(args.archive)
    except (OSError, ValueError, zipfile.BadZipFile, tarfile.TarError) as exc:
        print("ERROR: " + str(exc), file=sys.stderr)
        return 2
    if args.json:
        print(json.dumps(report, indent=2))
    else:
        print(f"{report['decision']}: {report['file']} ({report['format']})")
        print(f"Entries: {report['entries_scanned']}; declared bytes: {report['declared_uncompressed_bytes']}")
        for finding in report["findings"]:
            print(" - " + finding)
        print(report["warning"])
    return 1 if report["findings"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
