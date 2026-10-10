"""In-memory catalogue for the DemoMart storefront fixture."""
from __future__ import annotations

from typing import Final

PRODUCTS: Final[list[dict[str, object]]] = [
    {
        "id": 1,
        "sku": "WM-001",
        "name": "Wireless Mouse",
        "description": "Ergonomic 2.4 GHz wireless mouse with silent switches.",
        "price": 19.99,
        "category": "Accessories",
        "stock": 42,
    },
    {
        "id": 2,
        "sku": "UH-002",
        "name": "USB-C Hub",
        "description": "Seven-in-one hub with HDMI, USB 3.0, and SD readers.",
        "price": 34.50,
        "category": "Accessories",
        "stock": 17,
    },
    {
        "id": 3,
        "sku": "MK-003",
        "name": "Mechanical Keyboard",
        "description": "Tactile brown switches with per-key backlight.",
        "price": 89.00,
        "category": "Peripherals",
        "stock": 0,
    },
    {
        "id": 4,
        "sku": "MS-004",
        "name": "27-inch 4K Monitor",
        "description": "IPS panel, 99% sRGB, USB-C power delivery.",
        "price": 329.00,
        "category": "Displays",
        "stock": 8,
    },
]

USERS: Final[dict[str, dict[str, str]]] = {
    "tester@example.com": {"password": "DemoPass123!", "name": "Test User", "role": "customer"},
    "viewer@example.com": {"password": "ViewerPass123!", "name": "Viewer", "role": "viewer"},
}
