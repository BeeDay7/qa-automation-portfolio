"""Pydantic models for the Azam Trading Store."""

from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, EmailStr, Field


class Product(BaseModel):
    id: int
    sku: str
    name: str
    description: str
    price: float
    category: str
    stock: int
    image: str = ""
    origin: str = ""
    material: str = ""
    dimensions: str = ""
    weight: str = ""
    featured: bool = False


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


class OrderItem(BaseModel):
    id: int
    name: str
    price: float
    quantity: int


class Order(BaseModel):
    id: int
    created_at: datetime
    customer_email: str
    items: list[OrderItem]
    subtotal: float
    total: float
    status: str = "received"
