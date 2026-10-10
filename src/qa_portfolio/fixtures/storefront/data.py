"""Catalogue and store metadata for the Azam Trading Store fixture."""

from __future__ import annotations

from typing import Any, Final

STORE: Final[dict[str, str]] = {
    "name": "Azam Trading Store",
    "short": "Azam",
    "brand_mark": "AZ",
    "email": "azamtradingstore@gmail.com",
    "phone": "+234 803 585 1998",
    "address": "Abuja, Nigeria",
    "tagline": "Quality goods, honest prices.",
    "footer_note": "Azam Trading Store is a local test fixture. No real transactions occur.",
    "domain": "azamtradingstore.com",
}

_STATIC = "/static/products"

PRODUCTS: Final[list[dict[str, Any]]] = [
    {
        "id": 1,
        "sku": "AZ-WM-001",
        "name": "Wireless Mouse",
        "description": "Ergonomic 2.4 GHz wireless mouse with silent switches.",
        "price": 19.99,
        "category": "Accessories",
        "stock": 42,
        "image": f"{_STATIC}/wireless-mouse.svg",
    },
    {
        "id": 2,
        "sku": "AZ-UH-002",
        "name": "USB-C Hub",
        "description": "Seven-in-one hub with HDMI 4K, USB 3.0 and SD readers.",
        "price": 34.50,
        "category": "Accessories",
        "stock": 17,
        "image": f"{_STATIC}/usb-c-hub.svg",
    },
    {
        "id": 3,
        "sku": "AZ-MK-003",
        "name": "Mechanical Keyboard",
        "description": "Tactile brown switches with per-key backlight.",
        "price": 89.00,
        "category": "Peripherals",
        "stock": 0,
        "image": f"{_STATIC}/mechanical-keyboard.svg",
    },
    {
        "id": 4,
        "sku": "AZ-MS-004",
        "name": "27-inch 4K Monitor",
        "description": "IPS panel with 99% sRGB coverage and USB-C power delivery.",
        "price": 329.00,
        "category": "Displays",
        "stock": 8,
        "image": f"{_STATIC}/4k-monitor.svg",
    },
    {
        "id": 5,
        "sku": "AZ-HP-005",
        "name": "Over-Ear Headphones",
        "description": "Active noise cancellation with 40-hour battery.",
        "price": 149.00,
        "category": "Audio",
        "stock": 23,
        "image": f"{_STATIC}/headphones.svg",
    },
    {
        "id": 6,
        "sku": "AZ-WC-006",
        "name": "1080p Webcam",
        "description": "Full-HD webcam with dual noise-cancelling microphones.",
        "price": 59.00,
        "category": "Accessories",
        "stock": 31,
        "image": f"{_STATIC}/webcam.svg",
    },
    {
        "id": 7,
        "sku": "AZ-SSD-007",
        "name": "Portable SSD 1TB",
        "description": "NVMe portable drive, 1050 MB/s read, shock-resistant.",
        "price": 119.00,
        "category": "Storage",
        "stock": 14,
        "image": f"{_STATIC}/portable-ssd.svg",
    },
    {
        "id": 8,
        "sku": "AZ-MP-008",
        "name": "Extended Mousepad",
        "description": "900 x 400 mm desk mat with stitched edges.",
        "price": 24.00,
        "category": "Accessories",
        "stock": 55,
        "image": f"{_STATIC}/mousepad.svg",
    },
]

USERS: Final[dict[str, dict[str, str]]] = {
    "admin@azamtradingstore.com": {
        "password": "AzamAdmin!2026",
        "name": "Store Admin",
        "role": "admin",
    },
    "customer@example.com": {
        "password": "Customer!2026",
        "name": "Test Customer",
        "role": "customer",
    },
}
