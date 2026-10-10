"""Thin Robot Framework wrapper around the requests library.

Centralises base-URL handling, JSON decoding, and response assertion helpers
so API suites stay readable.
"""
from __future__ import annotations

from typing import Any

import requests


class ApiClient:
    """Small convenience client for Robot tests."""

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self, base_url: str, timeout: float = 5.0) -> None:
        self._base_url = base_url.rstrip("/")
        self._timeout = timeout
        self._session = requests.Session()

    def get(self, path: str, params: dict[str, Any] | None = None) -> requests.Response:
        """GET `path` and return the raw response object."""
        return self._session.get(
            f"{self._base_url}{path}", params=params, timeout=self._timeout
        )

    def post(self, path: str, json: dict[str, Any] | None = None) -> requests.Response:
        """POST JSON to `path` and return the raw response object."""
        return self._session.post(
            f"{self._base_url}{path}", json=json, timeout=self._timeout
        )

    def expect_status(self, response: requests.Response, expected: int) -> None:
        """Raise AssertionError if `response.status_code` != `expected`."""
        if response.status_code != expected:
            raise AssertionError(
                f"Expected HTTP {expected} but received {response.status_code}: "
                f"{response.text[:200]}"
            )
