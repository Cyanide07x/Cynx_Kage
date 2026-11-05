
from datetime import datetime, timedelta, timezone
from pathlib import Path
import os

import jwt
from dotenv import load_dotenv
from pwdlib import PasswordHash

import secrets
from pwdlib import PasswordHash



# Load environment variables from backend/.env
BASE_DIR = Path(__file__).resolve().parents[2]
load_dotenv(BASE_DIR / ".env")


# JWT configuration
SECRET_KEY = os.getenv("JWT_SECRET_KEY")

if not SECRET_KEY:
    raise RuntimeError("JWT_SECRET_KEY is missing from backend/.env")

ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 15
REFRESH_TOKEN_EXPIRE_DAYS = 7


# Argon2 password hashing
password_hasher = PasswordHash.recommended()


def hash_password(password: str) -> str:
    """Hash a password before storing it in MySQL."""
    return password_hasher.hash(password)


def verify_password(
    plain_password: str,
    hashed_password: str
) -> bool:
    """Verify a submitted password against its hash."""
    return password_hasher.verify(
        plain_password,
        hashed_password
    )


def create_access_token(
    user_id: int,
    expires_delta: timedelta | None = None
) -> str:
    """Generate a JWT access token."""

    now = datetime.now(timezone.utc)

    expire = now + (
        expires_delta
        or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    )

    payload = {
        "sub": str(user_id),
        "iat": now,
        "exp": expire,
        "type": "access"
    }

    return jwt.encode(
        payload,
        SECRET_KEY,
        algorithm=ALGORITHM
    )


def decode_access_token(token: str) -> dict:
    """Verify and decode a JWT access token."""

    payload = jwt.decode(
        token,
        SECRET_KEY,
        algorithms=[ALGORITHM]
    )

    if payload.get("type") != "access":
        raise jwt.InvalidTokenError("Invalid token type")

    return payload



def create_refresh_token() -> str:
    """Generate a secure random refresh token."""
    return secrets.token_urlsafe(64)


def hash_refresh_token(token: str) -> str:
    """Hash a refresh token before storing it."""
    return password_hasher.hash(token)


def verify_refresh_token(
    plain_token: str,
    hashed_token: str
) -> bool:
    """Verify a refresh token against its stored hash."""
    return password_hasher.verify(
        plain_token,
        hashed_token
    )
