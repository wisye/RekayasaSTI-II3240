from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import date, datetime

class UserBase(BaseModel):
        username: str
        email: EmailStr

class UserCreate(UserBase):
        password: str
        role: str

class UserResponse(UserBase):
        id: int
        role: str
        created_at: datetime

class Token(BaseModel):
        access_token: str
        token_type: str

class TokenData(BaseModel):
        username: Optional[str] = None
        user_id: Optional[int] = None
        role: Optional[str] = None

class ProductBase(BaseModel):
        name: str
        description: Optional[str] = None
        max_temperature: Optional[float] = None
        min_temperature: Optional[float] = None
        max_humidity: Optional[float] = None
        min_humidity: Optional[float] = None

class ProductCreate(ProductBase):
        pass

class ProductResponse(ProductBase):
        id: int
        product_code: str
        manufacturer_id: int
        created_at: datetime

class ShipmentItemBase(BaseModel):
        product_code: str
        quantity: int

class ShipmentCreate(BaseModel):
        shipping_date: date
        recipient_name: str
        recipient_address: str
        recipient_phone: str
        items: List[ShipmentItemBase]
        additional_info: Optional[str] = None

class ShipmentItem(BaseModel):
        product_id: int
        product_name: str
        quantity: int
        constraints_violated: bool

class ShipmentResponse(BaseModel):
        shipment_code: str
        shipping_date: date
        delivery_date: Optional[date] = None
        recipient_name: str
        recipient_address: str
        recipient_phone: str
        status: str
        constraints_violated: bool
        items: List[ShipmentItem]
        additional_info: Optional[str] = None

class NFCTagVerification(BaseModel):
        tag_id: str

class NFCTagResponse(BaseModel):
        is_authentic: bool
        product_name: Optional[str] = None
        manufacturer: Optional[str] = None
        shipment_code: Optional[str] = None

class NotificationCreate(BaseModel):
        shipment_code: str
        message: str

class NotificationResponse(BaseModel):
        id: int
        user_id: int
        shipment_id: int
        message: str
        read: bool
        created_at: datetime
        shipment_code: str