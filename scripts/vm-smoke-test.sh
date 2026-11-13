#!/usr/bin/env bash
# Boot the generated live ISO in an isolated, software-emulated QEMU VM.
# No host disks or network interfaces are attached. The ISO is read-only.
set -Eeuo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: bash scripts/vm-smoke-test.sh <live.iso> [evidence-directory]" >&2
  exit 2
fi

ISO_PATH="$(realpath "$1")"
OUT_DIR="${2:-vm-smoke-evidence}"
mkdir -p "$OUT_DIR"
OUT_DIR="$(realpath "$OUT_DIR")"

if [[ ! -s "$ISO_PATH" ]]; then
  echo "ISO is missing or empty: $ISO_PATH" >&2
  exit 2
fi

for command_name in qemu-system-x86_64 tesseract python3; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Required command is missing: $command_name" >&2
    exit 2
  fi
done

MONITOR_SOCKET="$OUT_DIR/qemu-monitor.sock"
QEMU_LOG="$OUT_DIR/qemu.log"
SCREENSHOT="$OUT_DIR/desktop.ppm"
OCR_BASE="$OUT_DIR/desktop"
OCR_TEXT="$OCR_BASE.txt"
RESULT="$OUT_DIR/result.txt"
QEMU_PID=""

cleanup() {
  if [[ -n "$QEMU_PID" ]] && kill -0 "$QEMU_PID" 2>/dev/null; then
    kill "$QEMU_PID" 2>/dev/null || true
    wait "$QEMU_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

rm -f "$MONITOR_SOCKET" "$SCREENSHOT" "$OCR_TEXT"
: > "$QEMU_LOG"

echo "Starting BIOS live-ISO boot in QEMU TCG (3 GiB RAM, 2 vCPUs, no NIC, no host disk)."
qemu-system-x86_64 \
  -machine pc,accel=tcg \
  -cpu max \
  -m 3072 \
  -smp 2 \
  -vga std \
  -drive "file=$ISO_PATH,media=cdrom,readonly=on" \
  -boot order=d \
  -nic none \
  -display vnc=127.0.0.1:1 \
  -monitor "unix:$MONITOR_SOCKET,server,nowait" \
  -no-reboot \
  -no-shutdown \
  >"$QEMU_LOG" 2>&1 &
QEMU_PID=$!

for _ in $(seq 1 30); do
  if [[ -S "$MONITOR_SOCKET" ]]; then
    break
  fi
  if ! kill -0 "$QEMU_PID" 2>/dev/null; then
    echo "QEMU exited before creating its monitor socket." >&2
    cat "$QEMU_LOG" >&2
    exit 1
  fi
  sleep 1
done

if [[ ! -S "$MONITOR_SOCKET" ]]; then
  echo "QEMU monitor socket did not become ready." >&2
  cat "$QEMU_LOG" >&2
  exit 1
fi

# Debian's live GRUB menu can remain interactive in headless QEMU.
# Give firmware/GRUB time to render, then press Enter on the default live entry.
echo "Selecting the default Debian live entry from the GRUB menu."
sleep 8
python3 - "$MONITOR_SOCKET" <<'PY'
import socket
import sys
import time

monitor_path = sys.argv[1]
sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
sock.settimeout(5)
sock.connect(monitor_path)

def read_prompt():
    data = bytearray()
    deadline = time.monotonic() + 5
    while b"(qemu)" not in data and time.monotonic() < deadline:
        try:
            chunk = sock.recv(4096)
        except socket.timeout:
            break
        if not chunk:
            break
        data.extend(chunk)
    return bytes(data)

read_prompt()
sock.sendall(b"sendkey ret\n")
read_prompt()
sock.close()
PY
sleep 5

echo "Waiting up to 252 seconds for the XFCE desktop to appear."
for attempt in $(seq 1 36); do
  if ! kill -0 "$QEMU_PID" 2>/dev/null; then
    echo "QEMU exited during guest boot." >&2
    cat "$QEMU_LOG" >&2
    exit 1
  fi

  rm -f "$SCREENSHOT"
  if ! python3 - "$MONITOR_SOCKET" "$SCREENSHOT" <<'PY'
import socket
import sys
import time

monitor_path, screenshot_path = sys.argv[1:3]
sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
sock.settimeout(5)
sock.connect(monitor_path)

def read_prompt():
    data = bytearray()
    deadline = time.monotonic() + 5
    while b"(qemu)" not in data and time.monotonic() < deadline:
        try:
            chunk = sock.recv(4096)
        except socket.timeout:
            break
        if not chunk:
            break
        data.extend(chunk)
    return bytes(data)

read_prompt()
sock.sendall(f"screendump {screenshot_path}\n".encode())
response = read_prompt()
sock.close()

if b"Error" in response or b"Could not" in response:
    raise SystemExit(response.decode(errors="replace"))
PY
  then
    echo "QEMU screenshot capture did not succeed on attempt $attempt." >&2
  fi

  if [[ -s "$SCREENSHOT" ]]; then
    tesseract "$SCREENSHOT" "$OCR_BASE" --psm 6 2>/dev/null || true
    if [[ -s "$OCR_TEXT" ]] && grep -Eqi 'Applications|Whisker Menu|Nexus OS|Nexus LUMEN' "$OCR_TEXT"; then
      {
        echo "PASS: QEMU BIOS boot reached the XFCE desktop."
        echo "ISO: $ISO_PATH"
        echo "Attempt: $attempt"
        echo "Evidence: desktop.ppm and desktop.txt"
        echo "Isolation: TCG, read-only ISO, no host disk, no network."
      } | tee "$RESULT"
      exit 0
    fi
  fi

  sleep 7
done

{
  echo "FAIL: QEMU remained available but the XFCE desktop marker was not detected."
  echo "The screenshot and OCR output are retained for diagnosis."
} | tee "$RESULT" >&2
if [[ -s "$OCR_TEXT" ]]; then
  echo "--- OCR output ---" >&2
  cat "$OCR_TEXT" >&2
fi
echo "--- QEMU log ---" >&2
tail -n 80 "$QEMU_LOG" >&2
exit 1
