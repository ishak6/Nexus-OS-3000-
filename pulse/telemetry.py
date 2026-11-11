#!/usr/bin/env python3
"""Read-only Linux telemetry sampler for Nexus Pulse.

Reads procfs only; it does not invoke shell commands or modify system state.
"""
import argparse
import json
import time
from pathlib import Path


class ProcTelemetry:
    def __init__(self, proc_root="/proc"):
        self.root = Path(proc_root)
        self._previous_cpu = None
        self._previous_net = None

    def _read_cpu(self):
        line = (self.root / "stat").read_text(encoding="ascii").splitlines()[0]
        values = [int(value) for value in line.split()[1:]]
        idle = values[3] + (values[4] if len(values) > 4 else 0)
        total = sum(values)
        return total, idle

    def _read_memory(self):
        values = {}
        for line in (self.root / "meminfo").read_text(encoding="ascii").splitlines():
            key, raw = line.split(":", 1)
            parts = raw.strip().split()
            if parts and parts[0].isdigit():
                values[key] = int(parts[0]) * (1024 if len(parts) > 1 and parts[1] == "kB" else 1)
        total = values.get("MemTotal", 0)
        available = values.get("MemAvailable", values.get("MemFree", 0))
        used = max(total - available, 0)
        return {"total_bytes": total, "used_bytes": used,
                "available_bytes": available,
                "used_percent": round(used * 100 / total, 1) if total else None}

    def _read_network(self):
        interfaces = {}
        lines = (self.root / "net" / "dev").read_text(encoding="ascii").splitlines()[2:]
        for line in lines:
            if ":" not in line:
                continue
            name, raw = line.split(":", 1)
            fields = raw.split()
            if len(fields) >= 9:
                interfaces[name.strip()] = {
                    "rx_bytes": int(fields[0]), "tx_bytes": int(fields[8])
                }
        return interfaces

    def sample(self):
        total, idle = self._read_cpu()
        cpu_percent = None
        if self._previous_cpu is not None:
            old_total, old_idle = self._previous_cpu
            delta_total, delta_idle = total - old_total, idle - old_idle
            if delta_total > 0:
                cpu_percent = round(max(0.0, min(100.0,
                    (delta_total - delta_idle) * 100.0 / delta_total)), 1)
        self._previous_cpu = (total, idle)

        network = self._read_network()
        deltas = {}
        if self._previous_net is not None:
            for name, current in network.items():
                old = self._previous_net.get(name)
                if old is not None:
                    deltas[name] = {
                        "rx_bytes_per_interval": max(0, current["rx_bytes"] - old["rx_bytes"]),
                        "tx_bytes_per_interval": max(0, current["tx_bytes"] - old["tx_bytes"])
                    }
        self._previous_net = network

        return {
            "schema_version": 1,
            "timestamp_unix": time.time(),
            "cpu": {"usage_percent_since_previous_sample": cpu_percent},
            "memory": self._read_memory(),
            "network": {"interfaces": network, "deltas": deltas},
            "source": "procfs",
            "read_only": True
        }


def main():
    parser = argparse.ArgumentParser(description="Emit read-only Nexus Pulse telemetry as JSON.")
    parser.add_argument("--proc-root", default="/proc", help=argparse.SUPPRESS)
    parser.add_argument("--interval", type=float, default=0,
                        help="seconds between samples; 0 emits one sample")
    args = parser.parse_args()
    if args.interval < 0:
        parser.error("--interval must be non-negative")
    sampler = ProcTelemetry(args.proc_root)
    while True:
        print(json.dumps(sampler.sample(), sort_keys=True), flush=True)
        if args.interval == 0:
            break
        time.sleep(args.interval)


if __name__ == "__main__":
    main()
