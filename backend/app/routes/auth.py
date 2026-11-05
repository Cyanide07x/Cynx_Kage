
from datetime import datetime, timedelta, timezone

from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    status,
    Body,
)
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.user import User
from app.models.refresh_token import RefreshToken
from app.schemas.auth import (
    RegisterRequest,
    LoginRequest,
    TokenResponse,
    UserResponse,
)
from app.core.security import (
    hash_password,
    verify_password,
    create_access_token,
    create_refresh_token,
    hash_refresh_token,
    verify_refresh_token,
)
from app.dependencies.auth import get_current_user


router = APIRouter(prefix="/auth", tags=["Authentication"])

REFRESH_TOKEN_EXPIRE_DAYS = 7


def issue_tokens(db: Session, user: User) -> dict:
    """Create and store a new access and refresh token pair."""

    raw_refresh_token = create_refresh_token()

    refresh_token_record = RefreshToken(
        user_id=user.user_id,
        token_hash=hash_refresh_token(raw_refresh_token),
        expires_at=(
            datetime.now(timezone.utc).replace(tzinfo=None)
            + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
        ),
    )

    db.add(refresh_token_record)

    return {
        "access_token": create_access_token(user.user_id),
        "refresh_token": raw_refresh_token,
        "token_type": "bearer",
        "user": UserResponse.model_validate(user),
    }


def find_refresh_token(
    db: Session,
    raw_token: str,
) -> RefreshToken | None:
    """Find an active refresh-token record matching the supplied token."""

    now = datetime.now(timezone.utc).replace(tzinfo=None)

    records = (
        db.query(RefreshToken)
        .filter(
            RefreshToken.is_revoked.is_(False),
            RefreshToken.expires_at > now,
        )
        .with_for_update()
        .all()
    )

    for record in records:
        if verify_refresh_token(raw_token, record.token_hash):
            return record

    return None


@router.post(
    "/register",
    response_model=TokenResponse,
    status_code=status.HTTP_201_CREATED,
)
def register(
    data: RegisterRequest,
    db: Session = Depends(get_db),
):
    email = data.email.lower().strip()

    existing_user = db.query(User).filter(
        User.email == email
    ).first()

    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email is already registered",
        )

    if data.phone:
        existing_phone = db.query(User).filter(
            User.phone == data.phone
        ).first()

        if existing_phone:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Phone number is already registered",
            )

    user = User(
        full_name=data.full_name.strip(),
        email=email,
        password_hash=hash_password(data.password),
        phone=data.phone,
        role="customer",
        is_active=True,
    )

    try:
        db.add(user)
        db.flush()

        result = issue_tokens(db, user)

        db.commit()
        return result

    except Exception:
        db.rollback()
        raise


@router.post(
    "/login",
    response_model=TokenResponse,
)
def login(
    data: LoginRequest,
    db: Session = Depends(get_db),
):
    email = data.email.lower().strip()

    user = db.query(User).filter(
        User.email == email
    ).first()

    if not user or not verify_password(
        data.password,
        user.password_hash,
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Your account has been deactivated",
        )

    try:
        result = issue_tokens(db, user)
        db.commit()
        return result

    except Exception:
        db.rollback()
        raise


@router.get(
    "/me",
    response_model=UserResponse,
)
def get_profile(
    current_user: User = Depends(get_current_user),
):
    return current_user


@router.post("/refresh")
def refresh_access_token(
    refresh_token: str = Body(..., embed=True),
    db: Session = Depends(get_db),
):
    """Rotate the refresh token and issue a new access token."""

    try:
        old_record = find_refresh_token(db, refresh_token)

        if old_record is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid, expired, or revoked refresh token",
            )

        user = db.query(User).filter(
            User.user_id == old_record.user_id
        ).first()

        if user is None or not user.is_active:
            db.rollback()
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User account is unavailable",
            )

        # Revoke the old refresh token.
        old_record.is_revoked = True

        # Issue a completely new token pair.
        result = issue_tokens(db, user)

        db.commit()
        return result

    except HTTPException:
        db.rollback()
        raise

    except Exception:
        db.rollback()
        raise


@router.post("/logout")
def logout(
    refresh_token: str = Body(..., embed=True),
    db: Session = Depends(get_db),
):
    """Revoke the supplied refresh-token session."""

    try:
        record = find_refresh_token(db, refresh_token)

        if record is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid, expired, or already revoked refresh token",
            )

        record.is_revoked = True
        db.commit()

        return {
            "message": "Successfully logged out"
        }

    except HTTPException:
        db.rollback()
        raise

    except Exception:
        db.rollback()
        raise
