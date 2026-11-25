"""Run the whole portfolio with one command, on Windows, macOS or Linux.

Starts the three fixture servers, waits until each one answers, runs the
selected Robot Framework suites, then stops the servers, even if a suite
fails or the run is interrupted.

Usage:
    python scripts/run_all.py                 # all suites: ui, security, api
    python scripts/run_all.py security api    # chosen suites only

Reports are written to evidence/<suite>/report.html. The exit code is
non-zero if any test failed.
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SUITES = ("ui", "security", "api")
HEALTH_URLS = (
    "http://127.0.0.1:8001/",
    "http://127.0.0.1:8002/",
    "http://127.0.0.1:8003/docs",
)


def _fixtures(flag: str) -> None:
    script = ROOT / "scripts" / "serve_fixtures.py"
    subprocess.run([sys.executable, str(script), flag], cwd=ROOT, check=True)


def _wait_until_ready(timeout: float = 30.0) -> None:
    deadline = time.monotonic() + timeout
    pending = list(HEALTH_URLS)
    while pending:
        url = pending[0]
        try:
            with urllib.request.urlopen(url, timeout=2):  # noqa: S310 (local fixture URL)
                pending.pop(0)
                continue
        except (urllib.error.URLError, ConnectionError, TimeoutError):
            if time.monotonic() > deadline:
                raise SystemExit(f"[run_all] fixture did not start: {url}") from None
            time.sleep(0.5)
    print("[run_all] fixtures ready on :8001, :8002, :8003")


def _run_suite(suite: str) -> int:
    cmd = [sys.executable, "-m", "robot", "--outputdir", f"evidence/{suite}", f"tests/{suite}"]
    print(f"\n[run_all] === {suite} ===")
    return subprocess.run(cmd, cwd=ROOT, env=os.environ.copy(), check=False).returncode


def main() -> int:
    parser = argparse.ArgumentParser(description="Start fixtures, run suites, stop fixtures.")
    parser.add_argument(
        "suites", nargs="*", metavar="SUITE", help="ui, security or api (default: all)"
    )
    args = parser.parse_args()
    unknown = sorted(set(args.suites) - set(SUITES))
    if unknown:
        parser.error(f"unknown suite(s): {', '.join(unknown)}; choose from {', '.join(SUITES)}")
    suites = args.suites or list(SUITES)

    _fixtures("--background")
    results: dict[str, int] = {}
    try:
        _wait_until_ready()
        for suite in suites:
            results[suite] = _run_suite(suite)
    finally:
        _fixtures("--stop")

    print("\n[run_all] summary")
    for suite, code in results.items():
        status = "PASS" if code == 0 else f"FAIL ({code} failed)"
        print(f"  {suite:<9} {status}    evidence/{suite}/report.html")
    return 0 if results and all(code == 0 for code in results.values()) else 1


if __name__ == "__main__":
    raise SystemExit(main())
