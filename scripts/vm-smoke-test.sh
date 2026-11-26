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
LUMEN_OCR_BASE="$OUT_DIR/lumen-window"
LUMEN_OCR_TEXT="$LUMEN_OCR_BASE.txt"
TOP_PANEL_SCREENSHOT="$OUT_DIR/desktop-top-panel.ppm"
TOP_PANEL_OCR_BASE="$OUT_DIR/desktop-top-panel"
TOP_PANEL_OCR_TEXT="$TOP_PANEL_OCR_BASE.txt"
GRUB_SCREENSHOT="$OUT_DIR/grub-after-timeout.ppm"
GRUB_OCR_BASE="$OUT_DIR/grub-after-timeout"
GRUB_OCR_TEXT="$OUT_DIR/grub-after-timeout.txt"
RESULT="$OUT_DIR/result.txt"
QEMU_PID=""

cleanup() {
  if [[ -n "$QEMU_PID" ]] && kill -0 "$QEMU_PID" 2>/dev/null; then
    kill "$QEMU_PID" 2>/dev/null || true
    wait "$QEMU_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

rm -f "$MONITOR_SOCKET" "$SCREENSHOT" "$OCR_TEXT" "$LUMEN_OCR_TEXT" \
  "$TOP_PANEL_SCREENSHOT" "$TOP_PANEL_OCR_TEXT" \
  "$GRUB_SCREENSHOT" "$GRUB_OCR_TEXT"
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

# The ISO selects GRUB for BIOS and UEFI. Let its configured five-second
# default-entry timeout finish before collecting desktop screenshots.
echo "Allowing the default live entry to boot automatically."
sleep 8
if python3 - "$MONITOR_SOCKET" "$GRUB_SCREENSHOT" <<'PY'
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
  tesseract "$GRUB_SCREENSHOT" "$GRUB_OCR_BASE" --psm 6 2>/dev/null || true
else
  echo "Could not capture the post-timeout GRUB diagnostic screenshot." >&2
fi

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
    # Sparse OCR catches the LUMEN workspace heading and system-card labels.
    tesseract "$SCREENSHOT" "$LUMEN_OCR_BASE" --psm 11 2>/dev/null || true

    # Tesseract full-screen PSM 6 can miss the small XFCE top-panel label.
    # Crop the top panel and OCR it separately, while checking desktop icons too.
    if python3 scripts/crop-ppm-top-panel.py "$SCREENSHOT" "$TOP_PANEL_SCREENSHOT" 45; then
      tesseract "$TOP_PANEL_SCREENSHOT" "$TOP_PANEL_OCR_BASE" --psm 6 2>/dev/null || true
    fi

    # LUMEN is foreground and covers XFCE desktop icons. Verify the panel/live-user
    # markers and actual LUMEN workspace content instead.
    if [[ -s "$OCR_TEXT" && -s "$TOP_PANEL_OCR_TEXT" && -s "$LUMEN_OCR_TEXT" ]] &&
      python3 scripts/verify-vm-desktop-markers.py "$OCR_TEXT" "$TOP_PANEL_OCR_TEXT" "$LUMEN_OCR_TEXT"; then
      {
        echo "PASS: QEMU BIOS boot reached XFCE with visible Nexus LUMEN UI content marker."
        echo "ISO: $ISO_PATH"
        echo "Attempt: $attempt"
        echo "Evidence: desktop.ppm, desktop.txt, lumen-window.txt, desktop-top-panel.ppm, and desktop-top-panel.txt"
        echo "Isolation: TCG, read-only ISO, no host disk, no network."
      } | tee "$RESULT"
      exit 0
    fi
  fi

  sleep 7
done

{
  echo "FAIL: QEMU remained available but XFCE or visible Nexus LUMEN UI content was not detected."
  echo "The full-screen, LUMEN sparse-text, and top-panel OCR outputs are retained for diagnosis."
} | tee "$RESULT" >&2
if [[ -s "$GRUB_OCR_TEXT" ]]; then
  echo "--- Post-timeout GRUB OCR output ---" >&2
  cat "$GRUB_OCR_TEXT" >&2
fi
if [[ -s "$OCR_TEXT" ]]; then
  echo "--- Final desktop OCR output ---" >&2
  cat "$OCR_TEXT" >&2
fi
if [[ -s "$TOP_PANEL_OCR_TEXT" ]]; then
  echo "--- Final XFCE top-panel OCR output ---" >&2
  cat "$TOP_PANEL_OCR_TEXT" >&2
fi
if [[ -s "$LUMEN_OCR_TEXT" ]]; then
  echo "--- Final LUMEN sparse-text OCR output ---" >&2
  cat "$LUMEN_OCR_TEXT" >&2
fi
echo "--- QEMU log ---" >&2
tail -n 80 "$QEMU_LOG" >&2
exit 1
