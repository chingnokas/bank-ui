from fastapi import FastAPI, APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from dotenv import load_dotenv
from starlette.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
import os
import logging
from pathlib import Path
from typing import List
from datetime import datetime, timedelta
import jwt
from passlib.context import CryptContext

# Import database models and dependencies
from database import (
    get_db, create_tables, StatusCheck, StatusCheckCreate, StatusCheckDB,
    User, UserCreate, UserDB, Account, AccountDB, Transaction, TransactionDB
)

ROOT_DIR = Path(__file__).parent
load_dotenv(ROOT_DIR / '.env')

# Create database tables
create_tables()

# Security setup
SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-change-in-production")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
security = HTTPBearer()

# Create the main app without a prefix
app = FastAPI(title="Peoples Bank API", version="1.0.0")

# Create a router with the /api prefix
api_router = APIRouter(prefix="/api")

# Security functions
def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

def create_access_token(data: dict, expires_delta: timedelta = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(credentials.credentials, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except jwt.PyJWTError:
        raise credentials_exception

    user = db.query(UserDB).filter(UserDB.id == user_id).first()
    if user is None:
        raise credentials_exception
    return user

# API Routes
@api_router.get("/")
async def root():
    return {"message": "Peoples Bank API - Secure Banking Platform"}

@api_router.post("/status", response_model=StatusCheck)
async def create_status_check(input: StatusCheckCreate, db: Session = Depends(get_db)):
    db_status = StatusCheckDB(client_name=input.client_name)
    db.add(db_status)
    db.commit()
    db.refresh(db_status)
    return StatusCheck(
        id=str(db_status.id),
        client_name=db_status.client_name,
        timestamp=db_status.timestamp
    )

@api_router.get("/status", response_model=List[StatusCheck])
async def get_status_checks(db: Session = Depends(get_db)):
    status_checks = db.query(StatusCheckDB).limit(1000).all()
    return [
        StatusCheck(
            id=str(status.id),
            client_name=status.client_name,
            timestamp=status.timestamp
        ) for status in status_checks
    ]

@api_router.post("/register", response_model=User)
async def register_user(user_data: UserCreate, db: Session = Depends(get_db)):
    # Check if user already exists
    existing_user = db.query(UserDB).filter(
        (UserDB.email == user_data.email) |
        (UserDB.account_number == user_data.account_number)
    ).first()

    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User with this email or account number already exists"
        )

    # Create new user
    hashed_password = get_password_hash(user_data.password)
    db_user = UserDB(
        account_number=user_data.account_number,
        name=user_data.name,
        email=user_data.email,
        phone=user_data.phone,
        password_hash=hashed_password
    )

    db.add(db_user)
    db.commit()
    db.refresh(db_user)

    return User(
        id=str(db_user.id),
        account_number=db_user.account_number,
        name=db_user.name,
        email=db_user.email,
        phone=db_user.phone,
        created_at=db_user.created_at,
        updated_at=db_user.updated_at
    )

@api_router.post("/login")
async def login(account_number: str, password: str, db: Session = Depends(get_db)):
    user = db.query(UserDB).filter(UserDB.account_number == account_number).first()

    if not user or not verify_password(password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect account number or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": str(user.id)}, expires_delta=access_token_expires
    )

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "id": str(user.id),
            "name": user.name,
            "account_number": user.account_number,
            "email": user.email
        }
    }

@api_router.get("/me", response_model=User)
async def get_current_user_info(current_user: UserDB = Depends(get_current_user)):
    return User(
        id=str(current_user.id),
        account_number=current_user.account_number,
        name=current_user.name,
        email=current_user.email,
        phone=current_user.phone,
        created_at=current_user.created_at,
        updated_at=current_user.updated_at
    )

# Include the router in the main app
app.include_router(api_router)

# Security: Restrict CORS for production
allowed_origins = os.getenv("ALLOWED_ORIGINS", "http://localhost:3000,http://frontend").split(",")

app.add_middleware(
    CORSMiddleware,
    allow_credentials=True,
    allow_origins=allowed_origins,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["*"],
)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

@app.on_event("startup")
async def startup_event():
    logger.info("Peoples Bank API starting up...")
    logger.info("Database tables created successfully")

@app.on_event("shutdown")
async def shutdown_event():
    logger.info("Peoples Bank API shutting down...")
