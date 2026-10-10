"""HTTP routes for the Azam Trading Store fixture."""

from __future__ import annotations

from pathlib import Path
from typing import Any

from fastapi import APIRouter, HTTPException, Request
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.templating import Jinja2Templates

from .data import (
    CATEGORIES,
    FOUNDING,
    PRINCIPLES,
    PRODUCTS,
    STORE,
    USERS,
)
from .models import AddItemRequest, CartItem, CartView, LoginRequest, Product

BASE_DIR = Path(__file__).parent
templates = Jinja2Templates(directory=str(BASE_DIR / "templates"))

router = APIRouter()
CART_KEY = "cart"
USER_KEY = "user_email"

CATEGORY_COUNT = max(len(CATEGORIES) - 1, 0)  # exclude the synthetic "All"


def _base_context(request: Request) -> dict[str, Any]:
    """Common template context every page needs."""
    return {
        "store": STORE,
        "categories": CATEGORIES,
        "category_count": CATEGORY_COUNT,
        "FOUNDING": FOUNDING,
        "PRINCIPLES": PRINCIPLES,
    }


def _current_user(request: Request) -> dict[str, Any] | None:
    """Return the current user record, or None if anonymous."""
    email = request.session.get(USER_KEY)
    if not email:
        return None
    record = USERS.get(email)
    if record is None:
        return None
    return {"email": email, **record}


def _cart_summary(request: Request) -> dict[str, Any]:
    """Return a small summary of the current basket."""
    items = list(request.session.get(CART_KEY, []))
    count = sum(int(i.get("quantity", 0)) for i in items)
    total = round(sum(float(i["price"]) * int(i["quantity"]) for i in items), 2)
    return {"count": count, "total": total, "items": items}


# ---------- pages ----------


@router.get("/", response_class=HTMLResponse, include_in_schema=False)
async def index(request: Request) -> HTMLResponse:
    ctx = _base_context(request)
    ctx["products"] = PRODUCTS
    return templates.TemplateResponse(request=request, name="index.html", context=ctx)


@router.get("/product/{product_id}", response_class=HTMLResponse, include_in_schema=False)
async def product_detail(request: Request, product_id: int) -> HTMLResponse:
    product = next((p for p in PRODUCTS if p["id"] == product_id), None)
    if product is None:
        return templates.TemplateResponse(
            request=request,
            name="not_found.html",
            context={**_base_context(request), "message": "That item is no longer on our shelves."},
            status_code=404,
        )

    related = [
        p for p in PRODUCTS if p["category"] == product["category"] and p["id"] != product["id"]
    ][:3]

    if len(related) < 3:
        extras = [p for p in PRODUCTS if p["id"] != product["id"] and p not in related]
        related.extend(extras[: 3 - len(related)])

    ctx = _base_context(request)
    ctx["product"] = product
    ctx["related"] = related
    return templates.TemplateResponse(request=request, name="product.html", context=ctx)


@router.get("/account", response_class=HTMLResponse, include_in_schema=False)
async def account(request: Request) -> HTMLResponse:
    user = _current_user(request)
    ctx = _base_context(request)
    ctx["user"] = user
    ctx["basket"] = _cart_summary(request)
    return templates.TemplateResponse(request=request, name="account.html", context=ctx)


# ---------- session ----------


@router.get("/api/session")
async def read_session(request: Request) -> JSONResponse:
    user = _current_user(request)
    return JSONResponse(
        {
            "authenticated": user is not None,
            "email": user["email"] if user else None,
            "name": user["name"] if user else None,
            "role": user["role"] if user else None,
        }
    )


@router.post("/api/login")
async def login(request: Request, body: LoginRequest) -> JSONResponse:
    record = USERS.get(str(body.email))
    if record is None or record["password"] != body.password:
        return JSONResponse({"error": "invalid_credentials"}, status_code=401)
    request.session[USER_KEY] = str(body.email)
    return JSONResponse({"ok": True, "name": record["name"], "role": record["role"]})


@router.post("/api/logout")
async def logout(request: Request) -> JSONResponse:
    request.session.clear()
    return JSONResponse({"ok": True})


# ---------- catalogue ----------


@router.get("/api/products")
async def list_products(q: str = "") -> JSONResponse:
    needle = q.strip().lower()
    items = [p for p in PRODUCTS if needle in str(p["name"]).lower()] if needle else list(PRODUCTS)
    return JSONResponse({"items": items, "count": len(items)})


@router.get("/api/products/{product_id}")
async def get_product(product_id: int) -> JSONResponse:
    item = next((p for p in PRODUCTS if p["id"] == product_id), None)
    if item is None:
        raise HTTPException(status_code=404, detail="product_not_found")
    return JSONResponse(Product.model_validate(item).model_dump())


# ---------- cart ----------


def _cart_view(items: list[dict[str, Any]]) -> CartView:
    view_items = [CartItem.model_validate(item) for item in items]
    total = round(sum(i.price * i.quantity for i in view_items), 2)
    return CartView(items=view_items, count=sum(i.quantity for i in view_items), total=total)


@router.get("/api/cart")
async def read_cart(request: Request) -> JSONResponse:
    items = list(request.session.get(CART_KEY, []))
    return JSONResponse(_cart_view(items).model_dump())


@router.post("/api/cart/items")
async def add_item(request: Request, body: AddItemRequest) -> JSONResponse:
    product = next((p for p in PRODUCTS if p["id"] == body.product_id), None)
    if product is None:
        raise HTTPException(status_code=404, detail="product_not_found")
    items = list(request.session.get(CART_KEY, []))
    existing = next((i for i in items if i["id"] == product["id"]), None)
    if existing:
        existing["quantity"] += 1
    else:
        items.append(
            {
                "id": product["id"],
                "name": product["name"],
                "price": product["price"],
                "quantity": 1,
            }
        )
    request.session[CART_KEY] = items
    return JSONResponse(_cart_view(items).model_dump())


@router.post("/api/cart/clear")
async def clear_cart(request: Request) -> JSONResponse:
    request.session[CART_KEY] = []
    return JSONResponse({"ok": True})


# ---------- checkout ----------


@router.post("/api/checkout")
async def checkout(request: Request) -> JSONResponse:
    if not request.session.get(USER_KEY):
        return JSONResponse({"message": "Please sign in before checkout."}, status_code=401)
    items = request.session.get(CART_KEY, [])
    if not items:
        return JSONResponse({"message": "Your cart is empty."})
    request.session[CART_KEY] = []
    return JSONResponse({"message": "Order submitted successfully (demo)."})
