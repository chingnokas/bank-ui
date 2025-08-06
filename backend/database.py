"""
Database configuration and models for PostgreSQL migration
"""
import os
from sqlalchemy import create_engine, Column, String, DateTime, Text, Integer
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy.dialects.postgresql import UUID
import uuid
from datetime import datetime
from pydantic import BaseModel, Field
from typing import List, Optional

# Database URL from environment
DATABASE_URL = os.getenv(
    "DATABASE_URL", 
    "postgresql://bankuser:bankpass@postgres:5432/bankdb"
)

# SQLAlchemy setup
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Database Models
class StatusCheckDB(Base):
    __tablename__ = "status_checks"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    client_name = Column(String(255), nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow)

class UserDB(Base):
    __tablename__ = "users"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    account_number = Column(String(20), unique=True, nullable=False, index=True)
    name = Column(String(255), nullable=False)
    email = Column(String(255), unique=True, nullable=False, index=True)
    phone = Column(String(20))
    password_hash = Column(String(255), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class AccountDB(Base):
    __tablename__ = "accounts"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    account_number = Column(String(20), unique=True, nullable=False, index=True)
    account_type = Column(String(50), nullable=False)  # 'current', 'savings', etc.
    balance = Column(Integer, nullable=False, default=0)  # Store as cents for precision
    currency = Column(String(3), default='ZAR')
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class TransactionDB(Base):
    __tablename__ = "transactions"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    account_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    transaction_type = Column(String(50), nullable=False)  # 'debit', 'credit'
    amount = Column(Integer, nullable=False)  # Store as cents
    description = Column(Text)
    reference = Column(String(100))
    balance_after = Column(Integer, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

# Pydantic Models for API
class StatusCheck(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    client_name: str
    timestamp: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True

class StatusCheckCreate(BaseModel):
    client_name: str

class User(BaseModel):
    id: str
    account_number: str
    name: str
    email: str
    phone: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class UserCreate(BaseModel):
    account_number: str
    name: str
    email: str
    phone: Optional[str] = None
    password: str

class Account(BaseModel):
    id: str
    user_id: str
    account_number: str
    account_type: str
    balance: float  # Convert from cents in the service layer
    currency: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class Transaction(BaseModel):
    id: str
    account_id: str
    transaction_type: str
    amount: float  # Convert from cents in the service layer
    description: Optional[str] = None
    reference: Optional[str] = None
    balance_after: float
    created_at: datetime

    class Config:
        from_attributes = True

# Database dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Create tables
def create_tables():
    Base.metadata.create_all(bind=engine)
