"""Robot Framework library that captures screenshots and appends evidence
metadata to a run-scoped JSON file.

Designed to be called from `Test Teardown` and `Suite Teardown` so each test
run produces a self-contained evidence bundle alongside Robot's own reports.
"""

from __future__ import annotations

import json
from datetime import UTC, datetime
from pathlib import Path
from typing import Any

from robot.libraries.BuiltIn import BuiltIn


class EvidenceHelper:
    """Capture screenshots and structured metadata for the current test run."""

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self, evidence_dir: str = "evidence/screenshots") -> None:
        self._dir = Path(evidence_dir)
        self._dir.mkdir(parents=True, exist_ok=True)

    def capture_on_failure(self) -> None:
        """Called from Test Teardown: saves a screenshot when the test failed."""
        builtin = BuiltIn()
        status = builtin.get_variable_value("${TEST STATUS}", default="UNKNOWN")
        if status == "PASS":
            return
        name = builtin.get_variable_value("${TEST NAME}", default="unnamed")
        safe = "".join(c if c.isalnum() or c in "-_" else "_" for c in str(name))
        timestamp = datetime.now(UTC).strftime("%Y%m%dT%H%M%S")
        target = self._dir / f"{safe}_{timestamp}.png"
        try:
            selenium: Any = builtin.get_library_instance("SeleniumLibrary")
            selenium.capture_page_screenshot(str(target))
        except Exception as exc:
            builtin.log(f"Screenshot skipped: {exc}", level="WARN")

    def record_run_metadata(self, extra: dict[str, object] | None = None) -> str:
        """Write a small JSON file summarising the current run."""
        builtin = BuiltIn()
        payload = {
            "generated_at_utc": datetime.now(UTC).isoformat(),
            "suite": builtin.get_variable_value("${SUITE NAME}", default=""),
            "test": builtin.get_variable_value("${TEST NAME}", default=""),
            "status": builtin.get_variable_value("${TEST STATUS}", default=""),
            "extra": extra or {},
        }
        path = self._dir.parent / "run_metadata.json"
        path.write_text(json.dumps(payload, indent=2), encoding="utf-8")
        return str(path)
