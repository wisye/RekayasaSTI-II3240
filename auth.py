from datetime import datetime, timedelta
from typing import Optional
import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from passlib.context import CryptContext
from database import get_db
from models import TokenData

SECRET_KEY = "YOUR_SECRET_KEY"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE = 60 * 60 * 24

pwd_context = CryptContext(schemes=["bcrypt"])
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="api/login")

def verify_password(plain_password, hashed_password):
        return pwd_context.verify(plain_password, hashed_password)

def get_hashed_password(password):
        return pwd_context.hash(password)

def create_token(data: dict, expires_delta: Optional[timedelta] = None):
        to_encode = data.copy()
        if expires_delta:
                expire = datetime.utcnow() + expires_delta
        else:
                expire = datetime.utcnow() + timedelta(seconds=ACCESS_TOKEN_EXPIRE)
        to_encode.update({"exp": expire})
        encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
        return encoded_jwt

def get_current_user(token: str = Depends(oauth2_scheme)):
        exception = HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Could not validate")
        try:
                payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
                username: str = payload.get("sub")
                user_id: int = payload.get("user_id")
                role: str = payload.get("role")
                if username is None or user_id is None:
                        raise exception
                token_data = TokenData(username=username, user_id=user_id, role=role)
        except jwt.PyJWTError:
                raise exception
        return token_data

def get_current_manufacturer(current_user: TokenData = Depends(get_current_user)):
        if current_user.role != "manufacturer":
                raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Unauthorized")
        return current_user

def get_current_recipient(current_user: TokenData = Depends(get_current_user)):
        if current_user.role != "recipient":
                raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Unauthorized")
        return current_user