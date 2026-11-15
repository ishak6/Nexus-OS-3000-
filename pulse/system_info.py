#!/usr/bin/env python3
"""Read-only operating-system identity and hardware inventory for Nexus Core.

The collector reads standard Linux metadata files only. It does not execute
commands, enumerate user data, or change system state.
"""
import argparse
import json
import platform
import shlex
import socket
from pathlib import Path


class SystemInfo:
    def __init__(self, proc_root="/proc", etc_root="/etc"):
        self.proc = Path(proc_root)
        self.etc = Path(etc_root)

    @staticmethod
    def _read_text(path):
        try:
            return path.read_text(encoding="utf-8").strip()
        except (OSError, UnicodeError):
            return None

    def _os_release(self):
        values = {}
        path = self.etc / "os-release"
        for line in (self._read_text(path) or "").splitlines():
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, raw = line.split("=", 1)
            if not key.replace("_", "").isalnum():
                continue
            try:
                parsed = shlex.split(raw, comments=False, posix=True)
                values[key] = parsed[0] if len(parsed) == 1 else raw
            except ValueError:
                values[key] = raw
        return {
            "name": values.get("PRETTY_NAME") or values.get("NAME"),
            "id": values.get("ID"),
            "version": values.get("VERSION_ID"),
            "codename": values.get("VERSION_CODENAME"),
        }

    def _memory(self):
        values = {}
        for line in (self._read_text(self.proc / "meminfo") or "").splitlines():
            if ":" not in line:
                continue
            key, raw = line.split(":", 1)
            parts = raw.split()
            if parts and parts[0].isdigit():
                values[key] = int(parts[0]) * (1024 if len(parts) > 1 and parts[1] == "kB" else 1)
        total = values.get("MemTotal")
        available = values.get("MemAvailable")
        return {
            "total_bytes": total,
            "available_bytes": available,
            "used_bytes": max(total - available, 0) if total is not None and available is not None else None,
        }

    def _cpu_model(self):
        for line in (self._read_text(self.proc / "cpuinfo") or "").splitlines():
            if line.lower().startswith(("model name", "hardware")) and ":" in line:
                return line.split(":", 1)[1].strip()
        return None

    def _uptime_seconds(self):
        raw = self._read_text(self.proc / "uptime")
        if not raw:
            return None
        try:
            return round(float(raw.split()[0]), 2)
        except (ValueError, IndexError):
            return None

    def collect(self):
        hostname = self._read_text(self.etc / "hostname") or socket.gethostname()
        return {
            "schema_version": 1,
            "os": self._os_release(),
            "kernel": {
                "release": platform.release(),
                "architecture": platform.machine(),
            },
            "host": {"hostname": hostname, "cpu_model": self._cpu_model()},
            "memory": self._memory(),
            "uptime_seconds": self._uptime_seconds(),
            "source": "linux-procfs-and-os-release",
            "read_only": True,
        }


def main():
    parser = argparse.ArgumentParser(description="Emit read-only Nexus OS system information as JSON.")
    parser.add_argument("--proc-root", default="/proc", help=argparse.SUPPRESS)
    parser.add_argument("--etc-root", default="/etc", help=argparse.SUPPRESS)
    args = parser.parse_args()
    print(json.dumps(SystemInfo(args.proc_root, args.etc_root).collect(), sort_keys=True))


if __name__ == "__main__":
    main()
