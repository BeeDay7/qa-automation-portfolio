"""Opinionated logging setup used by every fixture.

Produces structured, single-line logs that are easy to read in a terminal and
easy to parse in CI.
"""

from __future__ import annotations

import logging
import sys


def configure_logging(level: str = "INFO", service: str = "fixture") -> None:
    """Configure root logging once, idempotently."""
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(
        logging.Formatter(
            fmt=f"%(asctime)s | %(levelname)-7s | {service} | %(name)s | %(message)s",
            datefmt="%Y-%m-%dT%H:%M:%S",
        )
    )

    root = logging.getLogger()
    root.handlers.clear()
    root.addHandler(handler)
    root.setLevel(level.upper())

    # Quiet noisy third-party loggers
    logging.getLogger("uvicorn.access").setLevel(logging.WARNING)
    logging.getLogger("uvicorn.error").setLevel(logging.INFO)
