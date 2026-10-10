"""Launch and stop the three FastAPI fixture servers.

Usage:
    python scripts/serve_fixtures.py                 # foreground (Ctrl+C to stop)
    python scripts/serve_fixtures.py --background    # detach, write PIDs
    python scripts/serve_fixtures.py --stop          # stop detached servers
"""
from __future__ import annotations

import argparse
import os
import signal
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PID_DIR = ROOT / ".fixture-pids"

FIXTURES = [
    ("storefront",   "qa_portfolio.fixtures.storefront.app:app",   8001),
    ("secureportal", "qa_portfolio.fixtures.secureportal.app:app", 8002),
    ("api",          "qa_portfolio.fixtures.api.app:app",          8003),
]


def _spawn(target: str, port: int) -> subprocess.Popen[bytes]:
    env = {**os.environ, "PYTHONPATH": str(ROOT / "src")}
    cmd = [sys.executable, "-m", "uvicorn", target,
           "--host", "127.0.0.1", "--port", str(port), "--log-level", "info"]
    return subprocess.Popen(cmd, cwd=ROOT, env=env)


def start_foreground() -> int:
    procs = [(name, port, _spawn(target, port)) for name, target, port in FIXTURES]
    for name, port, proc in procs:
        print(f"[fixtures] {name:<12} → http://127.0.0.1:{port}  (pid {proc.pid})")
    try:
        for _, _, proc in procs:
            proc.wait()
    except KeyboardInterrupt:
        print("\n[fixtures] shutting down…")
        for _, _, proc in procs:
            proc.terminate()
    return 0


def start_background() -> int:
    PID_DIR.mkdir(exist_ok=True)
    for name, target, port in FIXTURES:
        proc = _spawn(target, port)
        (PID_DIR / f"{name}.pid").write_text(str(proc.pid))
        print(f"[fixtures] started {name} on :{port} (pid {proc.pid})")
    time.sleep(2.0)
    return 0


def stop_all() -> int:
    if not PID_DIR.exists():
        print("[fixtures] nothing to stop")
        return 0
    for pid_file in PID_DIR.glob("*.pid"):
        pid = int(pid_file.read_text())
        try:
            os.kill(pid, signal.SIGTERM)
            print(f"[fixtures] stopped pid {pid}")
        except ProcessLookupError:
            print(f"[fixtures] pid {pid} already gone")
        pid_file.unlink()
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Fixture control script.")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--background", action="store_true")
    group.add_argument("--stop", action="store_true")
    args = parser.parse_args()

    if args.stop:
        return stop_all()
    if args.background:
        return start_background()
    return start_foreground()


if __name__ == "__main__":
    raise SystemExit(main())
