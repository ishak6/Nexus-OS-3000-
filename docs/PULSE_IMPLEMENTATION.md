# Nexus Pulse telemetry

## Current implementation

`pulse/telemetry.py` is a read-only Linux procfs sampler. It reports:
- CPU utilization between consecutive samples (the first sample is explicitly null).
- Memory total, used, available and percentage.
- Per-interface receive/transmit byte counters and interval deltas.
- A timestamp, schema version, source and read-only marker.

It does not run shell commands, change system settings, collect packet contents, or transmit telemetry.

## Run

```sh
python3 pulse/telemetry.py
python3 pulse/telemetry.py --interval 2
```

Output is newline-delimited JSON. The interval mode samples continuously until stopped by the user.

## Verification and limitations

Run tests with:

```sh
python3 -m unittest discover -s pulse/tests -v
```

The sampler requires Linux procfs. CPU usage is unavailable until the second sample. Network deltas are byte counts per sampling interval, not a calibrated throughput rate. This service is not yet connected to the LUMEN UI; that integration is a separate release gate.
