"""Mock Product API fixture.

Demonstrates a clean, typed REST surface with OpenAPI available at /docs for
developer inspection. Not a production service.
"""
from __future__ import annotations

from fastapi import FastAPI, HTTPException, Query

from qa_portfolio.config import API
from qa_portfolio.logging_config import configure_logging

from .data import PRODUCTS
from .models import ErrorBody, Health, Product, ProductList

configure_logging(API.log_level, service="api")

app = FastAPI(
    title="Mock Product API",
    version="1.0.0",
    description="Local fixture used by the QA automation portfolio's API suite.",
)


@app.get("/health", response_model=Health, tags=["system"])
async def health() -> Health:
    return Health(status="ok", version=app.version)


@app.get("/api/v1/products", response_model=ProductList, tags=["products"])
async def list_products(
    in_stock: bool | None = Query(default=None, description="Filter to in-stock items only"),
    category: str | None = Query(default=None, description="Filter by category"),
) -> ProductList:
    items = list(PRODUCTS)
    if in_stock is True:
        items = [p for p in items if int(p["stock"]) > 0]
    if category:
        needle = category.lower()
        items = [p for p in items if str(p["category"]).lower() == needle]
    return ProductList(items=[Product(**p) for p in items], count=len(items))


@app.get(
    "/api/v1/products/{product_id}",
    response_model=Product,
    responses={404: {"model": ErrorBody}},
    tags=["products"],
)
async def get_product(product_id: int) -> Product:
    item = next((p for p in PRODUCTS if p["id"] == product_id), None)
    if item is None:
        raise HTTPException(status_code=404, detail="not_found")
    return Product(**item)
