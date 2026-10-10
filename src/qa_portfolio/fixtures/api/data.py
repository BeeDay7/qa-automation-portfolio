"""Static catalogue for the mock product API."""

from __future__ import annotations

from typing import Any, Final

PRODUCTS: Final[list[dict[str, Any]]] = [
    {
        "id": 1,
        "sku": "WM-001",
        "name": "Wireless Mouse",
        "price": 19.99,
        "stock": 42,
        "category": "Accessories",
    },
    {
        "id": 2,
        "sku": "UH-002",
        "name": "USB-C Hub",
        "price": 34.50,
        "stock": 17,
        "category": "Accessories",
    },
    {
        "id": 3,
        "sku": "MK-003",
        "name": "Mechanical Keyboard",
        "price": 89.00,
        "stock": 0,
        "category": "Peripherals",
    },
    {
        "id": 4,
        "sku": "MS-004",
        "name": "27-inch 4K Monitor",
        "price": 329.00,
        "stock": 8,
        "category": "Displays",
    },
]
