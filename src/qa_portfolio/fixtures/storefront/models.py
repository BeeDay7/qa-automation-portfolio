"""Pydantic models for the DemoMart storefront."""

from __future__ import annotations

from pydantic import BaseModel, EmailStr, Field


class Product(BaseModel):
    id: int
    sku: str
    name: str
    description: str
    price: float
    category: str
    stock: int


class LoginRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=1)


class AddItemRequest(BaseModel):
    product_id: int


class CartItem(BaseModel):
    id: int
    name: str
    price: float
    quantity: int = 1


class CartView(BaseModel):
    items: list[CartItem]
    count: int
    total: float
