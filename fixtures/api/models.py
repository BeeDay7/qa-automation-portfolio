"""Pydantic response models for the mock product API."""
from __future__ import annotations

from pydantic import BaseModel


class Product(BaseModel):
    id: int
    sku: str
    name: str
    price: float
    stock: int
    category: str


class ProductList(BaseModel):
    items: list[Product]
    count: int


class Health(BaseModel):
    status: str
    version: str


class ErrorBody(BaseModel):
    error: str
