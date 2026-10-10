"""Robot Framework library for loading structured test data from disk."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

import yaml


class DataLoader:
    """Load YAML or JSON fixtures relative to the repository root.

    Usage in a Robot suite::

        Library    qa_portfolio.libraries.DataLoader    root=${EXECDIR}

        ${users}=    Load Yaml File    tests/ui/data/users.yaml
        ${email}=    Get From Dictionary    ${users}[valid_user]    email
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"
    ROBOT_LIBRARY_VERSION = "1.0.0"

    def __init__(self, root: str | Path | None = None) -> None:
        self._root = Path(root) if root else Path.cwd()

    def load_yaml_file(self, relative_path: str) -> Any:
        """Return parsed YAML from `relative_path` under the configured root."""
        return yaml.safe_load(self._resolve(relative_path).read_text(encoding="utf-8"))

    def load_json_file(self, relative_path: str) -> Any:
        """Return parsed JSON from `relative_path` under the configured root."""
        return json.loads(self._resolve(relative_path).read_text(encoding="utf-8"))

    def _resolve(self, relative_path: str) -> Path:
        candidate = (self._root / relative_path).resolve()
        if not candidate.exists():
            raise FileNotFoundError(f"Data file not found: {candidate}")
        return candidate
