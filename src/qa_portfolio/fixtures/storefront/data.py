"""Catalogue and store metadata for the Azam Trading Store fixture.

The store is written as if it were a real merchant house — a family-run
trading business with a hand-bound ledger, a curated selection, and a voice
that speaks personally to each customer. Every field below is deliberate.

Design intent
-------------
The narrative layer (founding, principles, product stories) exists so the
templates can render a page that reads like a real merchant's catalogue
rather than a generic e-commerce grid. The data layer is the same shape as
a production system would use; only the copy is warmer.

Fixture contract
----------------
The QA suites depend on a small number of facts and those must never change
without also updating the tests:

- Wireless Mouse is priced at 19.99 and is in stock.
- USB-C Hub is priced at 34.50 and is in stock.
- Mechanical Keyboard has zero stock (used by DM-009 for the disabled button).

Every other field is free to evolve.
"""

from __future__ import annotations

from typing import Any, Final

# -----------------------------------------------------------------------------
# The house
# -----------------------------------------------------------------------------

STORE: Final[dict[str, str]] = {
    "name": "Azam Trading Store",
    "short": "Azam",
    "brand_mark": "AZ",
    "email": "azamtradingstore@gmail.com",
    "phone": "+234 803 585 1998",
    "address": "Abuja, Nigeria",
    "region": "Federal Capital Territory",
    "tagline": "Fine goods, chosen with care.",
    "subhead": (
        "A merchant house serving West Africa since 2019. Every item is "
        "inspected in Abuja before it leaves our shelves."
    ),
    "closing_line": ("You are welcome here. Take your time. Ask if you need anything."),
    "footer_note": (
        "Azam Trading Store is a self-directed test fixture. No real transactions occur."
    ),
    "domain": "azamtradingstore.com",
    "established": "2019",
    "opening_hours": "Monday to Saturday, 9am to 6pm WAT",
}

FOUNDING: Final[dict[str, str]] = {
    "eyebrow": "Our House",
    "headline": "Founded on a simple promise.",
    "body": (
        "Azam Trading Store began in 2019 with a single shelving unit, a "
        "ledger book, and a promise made to the first customer who walked "
        "through the door: that we would never sell anything we had not "
        "held in our own hands. That promise has not changed. It is the "
        "reason we open every box before it reaches the shelf, and the "
        "reason we would rather lose a sale than send something we would "
        "not keep ourselves."
    ),
    "signature": "The Azam family",
    "signature_role": "Founders & Keepers",
}

PRINCIPLES: Final[list[dict[str, str]]] = [
    {
        "number": "I",
        "title": "Hold it first",
        "body": (
            "Nothing reaches the shelf without passing through our own "
            "hands. Inspected, tested, and chosen on its merits."
        ),
    },
    {
        "number": "II",
        "title": "Speak plainly",
        "body": (
            "No inflated words, no sales tricks. We describe what an item "
            "is and let it speak for itself."
        ),
    },
    {
        "number": "III",
        "title": "Stand behind it",
        "body": (
            "If something is not right, we make it right. That has been "
            "true since the first sale, and it will be true at the last."
        ),
    },
]

CATEGORIES: Final[list[dict[str, str]]] = [
    {
        "key": "All",
        "label": "The full collection",
        "blurb": "Every item we currently hold in the house.",
    },
    {
        "key": "Accessories",
        "label": "Accessories",
        "blurb": "The small things that make the work feel considered.",
    },
    {
        "key": "Peripherals",
        "label": "Peripherals",
        "blurb": "Input devices for people who write and build all day.",
    },
    {
        "key": "Displays",
        "label": "Displays",
        "blurb": "Screens that earn their place on a working desk.",
    },
    {
        "key": "Audio",
        "label": "Audio",
        "blurb": "Quiet listening for long hours of concentration.",
    },
    {
        "key": "Storage",
        "label": "Storage",
        "blurb": "Somewhere safe to keep what matters.",
    },
]

# -----------------------------------------------------------------------------
# The catalogue
# -----------------------------------------------------------------------------

_STATIC: Final[str] = "/static/products"

PRODUCTS: Final[list[dict[str, Any]]] = [
    {
        "id": 1,
        "sku": "AZ-WM-001",
        "name": "Wireless Mouse",
        "description": (
            "A quiet companion for long working days. Silent switches, a "
            "shape that fits the hand, and enough battery to forget about "
            "for eighteen months."
        ),
        "story": (
            "The first item we ever sold, and still the one we recommend "
            "most often. It is not the cheapest mouse on the market and it "
            "is not the most technical. It is simply the one we have never "
            "had to apologise for."
        ),
        "price": 19.99,
        "category": "Accessories",
        "stock": 42,
        "image": f"{_STATIC}/wireless-mouse.svg",
        "featured": False,
        "origin": "Designed in Shenzhen, assembled in Vietnam",
        "material": "Matte ABS shell, silicone grip",
        "dimensions": "115 x 62 x 38 mm",
        "weight": "84 g",
    },
    {
        "id": 2,
        "sku": "AZ-UH-002",
        "name": "USB-C Hub",
        "description": (
            "Seven ports on a single cable. HDMI for the projector, USB-A "
            "for the older drives, SD for the camera card, and enough "
            "power to keep a laptop charging while everything else runs."
        ),
        "story": (
            "Built for the kind of desk where a laptop is closed and three "
            "screens are open. The kind of desk where you have one cable "
            "and it has to do everything."
        ),
        "price": 34.50,
        "category": "Accessories",
        "stock": 17,
        "image": f"{_STATIC}/usb-c-hub.svg",
        "featured": True,
        "origin": "Designed in Taipei",
        "material": "Anodised aluminium",
        "dimensions": "120 x 55 x 15 mm",
        "weight": "108 g",
    },
    {
        "id": 3,
        "sku": "AZ-MK-003",
        "name": "Mechanical Keyboard",
        "description": (
            "Brown switches, dampened. Per-key backlight you can turn all "
            "the way down. A machined aluminium frame that does not move "
            "when you type."
        ),
        "story": (
            "The board we use ourselves. It is quiet enough for an office "
            "and heavy enough that you feel every keystroke land. We have "
            "sold out twice and re-ordered twice. It is on order again."
        ),
        "price": 89.00,
        "category": "Peripherals",
        "stock": 0,
        "image": f"{_STATIC}/mechanical-keyboard.svg",
        "featured": True,
        "origin": "Designed in Kyoto, assembled in Dongguan",
        "material": "Anodised aluminium, PBT keycaps",
        "dimensions": "440 x 130 x 40 mm",
        "weight": "1.4 kg",
    },
    {
        "id": 4,
        "sku": "AZ-MS-004",
        "name": "27-inch 4K Monitor",
        "description": (
            "Four thousand by two thousand, one hundred and sixty. Ninety-"
            "nine percent sRGB out of the box. One cable carries picture "
            "and power, so the desk stays clear."
        ),
        "story": (
            "We kept three of these for our own workbench before we ever "
            "put one on the shelf. Colour is honest, the stand holds its "
            "angle, and the panel does not flicker at low brightness."
        ),
        "price": 329.00,
        "category": "Displays",
        "stock": 8,
        "image": f"{_STATIC}/4k-monitor.svg",
        "featured": True,
        "origin": "Panel sourced in Seoul, assembled in Penang",
        "material": "IPS panel, aluminium stand",
        "dimensions": "614 x 456 x 200 mm",
        "weight": "6.8 kg",
    },
    {
        "id": 5,
        "sku": "AZ-HP-005",
        "name": "Over-Ear Headphones",
        "description": (
            "Forty hours between charges. Noise cancelling that holds its "
            "own on a plane. Leather earcups soft enough that you forget "
            "you are wearing them."
        ),
        "story": (
            "For the work that requires silence, and for the music that "
            "makes the silence bearable. The battery life is not a "
            "marketing figure — we tested it on a flight to Nairobi and it "
            "did not need charging on the return."
        ),
        "price": 149.00,
        "category": "Audio",
        "stock": 23,
        "image": f"{_STATIC}/headphones.svg",
        "featured": False,
        "origin": "Designed in Copenhagen, assembled in Shenzhen",
        "material": "Aluminium headband, leather earcups",
        "dimensions": "180 x 170 x 80 mm",
        "weight": "245 g",
    },
    {
        "id": 6,
        "sku": "AZ-WC-006",
        "name": "1080p Webcam",
        "description": (
            "Two microphones, a shutter that closes, and a mount that "
            "actually holds. Fifty-nine dollars and no visible software "
            "required on the machine it is plugged into."
        ),
        "story": (
            "We were tired of webcams that cost twice as much and looked "
            "worse. This one does the job quietly and disappears from the "
            "desk when the lid closes."
        ),
        "price": 59.00,
        "category": "Accessories",
        "stock": 31,
        "image": f"{_STATIC}/webcam.svg",
        "featured": False,
        "origin": "Designed in Berlin, assembled in Shenzhen",
        "material": "Matte polycarbonate, glass lens",
        "dimensions": "72 x 68 x 42 mm",
        "weight": "112 g",
    },
    {
        "id": 7,
        "sku": "AZ-SSD-007",
        "name": "Portable SSD 1TB",
        "description": (
            "One thousand and fifty megabytes a second, in a case the size "
            "of a deck of cards. Drop it, sit on it, carry it in a coat "
            "pocket. It will not notice."
        ),
        "story": (
            "Our own archive lives on one of these. The photographs from "
            "the last four years, the accounts, the letters. It has "
            "survived two power cuts and one very bad taxi ride."
        ),
        "price": 119.00,
        "category": "Storage",
        "stock": 14,
        "image": f"{_STATIC}/portable-ssd.svg",
        "featured": False,
        "origin": "Controller designed in Milpitas",
        "material": "Anodised aluminium, silicone bumper",
        "dimensions": "100 x 55 x 10 mm",
        "weight": "56 g",
    },
    {
        "id": 8,
        "sku": "AZ-MP-008",
        "name": "Extended Mousepad",
        "description": (
            "Nine hundred by four hundred millimetres. Stitched edges that "
            "do not fray. A rubber base that keeps it exactly where you put "
            "it, on the first day and every day after."
        ),
        "story": (
            "The kind of object you do not think about until you have one. "
            "Then you cannot work without it. We have three on our own "
            "bench, one for each of us."
        ),
        "price": 24.00,
        "category": "Accessories",
        "stock": 55,
        "image": f"{_STATIC}/mousepad.svg",
        "featured": False,
        "origin": "Cut and stitched in Lagos",
        "material": "Micro-woven cloth, natural rubber",
        "dimensions": "900 x 400 x 3 mm",
        "weight": "340 g",
    },
]

# -----------------------------------------------------------------------------
# The register — customers and staff
# -----------------------------------------------------------------------------

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

# -----------------------------------------------------------------------------
# The Journal — notes from the keeper
# -----------------------------------------------------------------------------

JOURNAL: Final[list[dict[str, Any]]] = [
    {
        "slug": "we-open-every-box",
        "title": "We open every box",
        "eyebrow": "On inspection",
        "standfirst": (
            "Nothing reaches our shelves without passing through our own "
            "hands. A short note on why that rule has never changed."
        ),
        "date_iso": "2026-09-14",
        "date_display": "14 September 2026",
        "reading_minutes": 4,
        "author": "The Azam family",
        "author_role": "Founders & Keepers",
        "hero_image": "/static/journal/we-open-every-box.svg",
        "body": [
            (
                "The first rule of the house is simple: we do not sell what "
                "we have not held. Every box that arrives on our loading bay "
                "is opened. Every item is taken out, turned over, and placed "
                "on a workbench before it ever reaches a shelf. Some of them "
                "never make it that far."
            ),
            (
                "We started this in 2019 out of necessity. In the beginning, "
                "we could not afford the volume of a big distributor, and "
                "every wrong order hurt. So we opened everything, and we "
                "learned which suppliers we could trust and which we could "
                "not. The ones we could trust, we kept. The rest, we stopped "
                "buying from."
            ),
            (
                "The habit stuck. When a shipment of a hundred wireless mice "
                "arrived last spring with a hundred and three units in it — "
                "three extras, a small gift from the factory — we opened "
                "every one of them anyway. Two of them rattled when we "
                "picked them up. We sent the whole batch back. The supplier "
                "was not happy. We did not care. Our customers were not "
                "going to receive a mouse that rattled."
            ),
            (
                "There is a version of this business where you sell whatever "
                "arrives, apologise when it breaks, and replace it from a "
                "margin that is already thin. We have watched other shops do "
                "that. They do not last. The customer remembers. They tell "
                "one person, and that person tells two more, and in three "
                "years the shop is empty."
            ),
            (
                "We would rather lose a sale than send something we would "
                "not keep ourselves. That has been true since the first "
                "unit we ever sold, and it will be true at the last one. "
                "If you are ever uncertain whether something we stock is "
                "worth the price, ask us. We will tell you the truth, "
                "even when it costs us the order."
            ),
        ],
        "product_ids": [1, 2, 6],
    },
    {
        "slug": "fewer-better-things",
        "title": "The case for fewer, better things",
        "eyebrow": "On curation",
        "standfirst": (
            "Our catalogue is deliberately small. Here is why we keep it "
            "that way, and why it will probably get smaller."
        ),
        "date_iso": "2026-08-22",
        "date_display": "22 August 2026",
        "reading_minutes": 5,
        "author": "The Azam family",
        "author_role": "Founders & Keepers",
        "hero_image": "/static/journal/fewer-better-things.svg",
        "body": [
            (
                "Eight items. That is the whole catalogue. Some shops of our "
                "size carry a thousand. Some carry ten thousand. We carry "
                "eight, and next year we will probably carry fewer."
            ),
            (
                "There is a discipline that comes with refusing things. Every "
                "item we add is an item that has to justify itself against "
                "everything else on the shelf. Does it do something the "
                "others do not? Is it better than the version we already "
                "have? Would we recommend it over an item we stopped "
                "stocking last year? If the answer is no, it does not come in."
            ),
            (
                "The mechanical keyboard is a good example. We have sold "
                "four different keyboards in the life of this shop. Every "
                "one of them was good, and every one of them eventually lost "
                "its place to a better version. The current board is the "
                "fifth. It is the one we use ourselves. When the sixth "
                "arrives — and it will — we will not keep both. The fifth "
                "will come off the shelf."
            ),
            (
                "This is not minimalism for its own sake. It is the "
                "opposite. Minimalism as a style is another kind of "
                "abundance — you can always buy more of the aesthetic. What "
                "we are trying to do is harder: to know, without flinching, "
                "which things are worth keeping and which are not."
            ),
            (
                "You are welcome to disagree with any of our choices. If "
                "you have used something better than what we stock, tell "
                "us. We will buy it, test it, and if it wins, it goes on "
                "the shelf. That is how the catalogue grows and how it "
                "shrinks. And either direction is fine, so long as the "
                "shelf is honest."
            ),
        ],
        "product_ids": [3, 4, 7],
    },
    {
        "slug": "wrapped-by-hand",
        "title": "Wrapped by hand",
        "eyebrow": "On sending",
        "standfirst": (
            "Paper, twine, and a short note. The small ceremony of every "
            "parcel that leaves this house."
        ),
        "date_iso": "2026-07-30",
        "date_display": "30 July 2026",
        "reading_minutes": 3,
        "author": "The Azam family",
        "author_role": "Founders & Keepers",
        "hero_image": "/static/journal/wrapped-by-hand.svg",
        "body": [
            (
                "We wrap every order by hand. Not because we are slow, and "
                "not because we are trying to be precious. Because it is "
                "the last moment we have with a parcel before it belongs "
                "to someone else, and it is the one moment when we can "
                "still decide what kind of shop we want to be."
            ),
            (
                "The paper is unbleached kraft, thin enough to fold "
                "cleanly. The twine is natural jute, tied with a knot "
                "tight enough to survive the post but loose enough to be "
                "undone with one finger. Inside, on a small card, we write "
                "the name of the person who packed the parcel, and the day "
                "it was packed. There is no brand mark on the card. There "
                "is no logo. There is just a name and a date."
            ),
            (
                "When something goes wrong — when a parcel is late, or "
                "when an item arrives damaged, or when we simply made a "
                "mistake — the note is the first thing our customer sees. "
                "We do not write a template. We write what actually "
                "happened. Sometimes that means admitting we shipped the "
                "wrong thing. Sometimes it means explaining that the "
                "weather in Lagos was worse than usual and the courier "
                "could not reach the airport on time."
            ),
            (
                "This is the part of the business that scales worst. Every "
                "wrapped parcel is a minute of one of our lives. When we "
                "grow — and we are growing — we will have to decide "
                "whether to keep this rule. I hope we do. I suspect we "
                "will have to, because it is the one thing that makes "
                "this shop recognisable as itself."
            ),
            (
                "If a parcel from us ever reaches you, take a moment with "
                "the note before you unwrap it. Somebody wrote that for "
                "you specifically. It is small, but it is the whole point."
            ),
        ],
        "product_ids": [5, 8],
    },
]
