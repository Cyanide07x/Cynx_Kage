from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import text
from pydantic import BaseModel, Field

from app.database import get_db
from app.dependencies.auth import get_current_user
from app.models.user import User

router = APIRouter(
    prefix="/addresses",
    tags=["Addresses"]
)


# ── Pydantic Request Models ──────────────────────────────────────────────────

class AddressCreate(BaseModel):
    recipient_name: str | None = None
    name: str | None = None
    phone: str
    address_line1: str | None = None
    address: str | None = None
    address_line2: str | None = None
    landmark: str | None = None
    city: str
    state: str
    postal_code: str | None = None
    pin: str | None = None
    country: str = "India"
    address_type: str = "home"
    is_default: bool = False


class AddressUpdate(BaseModel):
    recipient_name: str | None = None
    name: str | None = None
    phone: str | None = None
    address_line1: str | None = None
    address: str | None = None
    address_line2: str | None = None
    landmark: str | None = None
    city: str | None = None
    state: str | None = None
    postal_code: str | None = None
    pin: str | None = None
    country: str | None = None
    address_type: str | None = None
    is_default: bool | None = None


# ── Helper Formatter ─────────────────────────────────────────────────────────

def _format_address(row: dict) -> dict:
    recipient = row.get("recipient_name") or ""
    line1 = row.get("address_line1") or ""
    code = row.get("postal_code") or ""
    return {
        "address_id": row["address_id"],
        "user_id": row["user_id"],
        "recipient_name": recipient,
        "name": recipient,
        "phone": row.get("phone") or "",
        "address_line1": line1,
        "address": line1,
        "address_line2": row.get("address_line2") or "",
        "landmark": row.get("landmark") or "",
        "city": row.get("city") or "",
        "state": row.get("state") or "",
        "postal_code": code,
        "pin": code,
        "country": row.get("country") or "India",
        "address_type": row.get("address_type") or "home",
        "is_default": bool(row.get("is_default")),
    }


# ── GET /addresses ───────────────────────────────────────────────────────────

@router.get("", include_in_schema=False)
@router.get("/")
def get_addresses(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    try:
        rows = db.execute(
            text("""
                SELECT *
                FROM addresses
                WHERE user_id = :user_id
                ORDER BY is_default DESC, created_at DESC
            """),
            {"user_id": current_user.user_id}
        ).mappings().all()

        return {
            "addresses": [_format_address(dict(row)) for row in rows]
        }
    except Exception as e:
        db.rollback()
        print("ADDRESSES GET ERROR:", repr(e))
        raise HTTPException(
            status_code=500,
            detail="Could not fetch addresses"
        )


# ── POST /addresses ──────────────────────────────────────────────────────────

@router.post("", include_in_schema=False, status_code=status.HTTP_201_CREATED)
@router.post("/", status_code=status.HTTP_201_CREATED)
def create_address(
    payload: AddressCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    try:
        recipient = (payload.recipient_name or payload.name or "").strip()
        line1 = (payload.address_line1 or payload.address or "").strip()
        code = (payload.postal_code or payload.pin or "").strip()

        if not recipient or not line1 or not code:
            raise HTTPException(
                status_code=400,
                detail="Name, address, and postal code are required"
            )

        # If marking this address as default, unset other defaults
        if payload.is_default:
            db.execute(
                text("UPDATE addresses SET is_default = 0 WHERE user_id = :user_id"),
                {"user_id": current_user.user_id}
            )

        # Check if user has any existing addresses. If this is their first address, make it default.
        existing_count = db.execute(
            text("SELECT COUNT(*) AS total FROM addresses WHERE user_id = :user_id"),
            {"user_id": current_user.user_id}
        ).scalar() or 0

        is_default_val = 1 if (payload.is_default or existing_count == 0) else 0

        valid_type = payload.address_type.lower()
        if valid_type not in ["home", "work", "other"]:
            valid_type = "home"

        result = db.execute(
            text("""
                INSERT INTO addresses (
                    user_id,
                    recipient_name,
                    phone,
                    address_line1,
                    address_line2,
                    landmark,
                    city,
                    state,
                    postal_code,
                    country,
                    address_type,
                    is_default
                ) VALUES (
                    :user_id,
                    :recipient_name,
                    :phone,
                    :address_line1,
                    :address_line2,
                    :landmark,
                    :city,
                    :state,
                    :postal_code,
                    :country,
                    :address_type,
                    :is_default
                )
            """),
            {
                "user_id": current_user.user_id,
                "recipient_name": recipient,
                "phone": payload.phone.strip(),
                "address_line1": line1,
                "address_line2": (payload.address_line2 or "").strip() or None,
                "landmark": (payload.landmark or "").strip() or None,
                "city": payload.city.strip(),
                "state": payload.state.strip(),
                "postal_code": code,
                "country": payload.country.strip() or "India",
                "address_type": valid_type,
                "is_default": is_default_val,
            }
        )
        address_id = result.lastrowid
        db.commit()

        row = db.execute(
            text("SELECT * FROM addresses WHERE address_id = :address_id"),
            {"address_id": address_id}
        ).mappings().first()

        return {
            "message": "Address created successfully",
            "address": _format_address(dict(row)) if row else None
        }

    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        print("ADDRESS CREATE ERROR:", repr(e))
        raise HTTPException(
            status_code=500,
            detail="Could not create address"
        )


# ── PUT /addresses/{address_id} ──────────────────────────────────────────────

@router.put("/{address_id}")
def update_address(
    address_id: int,
    payload: AddressUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    try:
        existing = db.execute(
            text("SELECT * FROM addresses WHERE address_id = :address_id AND user_id = :user_id"),
            {"address_id": address_id, "user_id": current_user.user_id}
        ).mappings().first()

        if not existing:
            raise HTTPException(status_code=404, detail="Address not found")

        recipient = payload.recipient_name or payload.name or existing["recipient_name"]
        line1 = payload.address_line1 or payload.address or existing["address_line1"]
        code = payload.postal_code or payload.pin or existing["postal_code"]
        phone = payload.phone or existing["phone"]
        city = payload.city or existing["city"]
        state = payload.state or existing["state"]
        address_line2 = payload.address_line2 if payload.address_line2 is not None else existing["address_line2"]
        landmark = payload.landmark if payload.landmark is not None else existing["landmark"]
        country = payload.country or existing["country"]
        address_type = payload.address_type or existing["address_type"]

        if payload.is_default is True:
            db.execute(
                text("UPDATE addresses SET is_default = 0 WHERE user_id = :user_id"),
                {"user_id": current_user.user_id}
            )
            is_default_val = 1
        elif payload.is_default is False:
            is_default_val = 0
        else:
            is_default_val = existing["is_default"]

        db.execute(
            text("""
                UPDATE addresses SET
                    recipient_name = :recipient_name,
                    phone = :phone,
                    address_line1 = :address_line1,
                    address_line2 = :address_line2,
                    landmark = :landmark,
                    city = :city,
                    state = :state,
                    postal_code = :postal_code,
                    country = :country,
                    address_type = :address_type,
                    is_default = :is_default
                WHERE address_id = :address_id AND user_id = :user_id
            """),
            {
                "recipient_name": recipient,
                "phone": phone,
                "address_line1": line1,
                "address_line2": address_line2,
                "landmark": landmark,
                "city": city,
                "state": state,
                "postal_code": code,
                "country": country,
                "address_type": address_type,
                "is_default": is_default_val,
                "address_id": address_id,
                "user_id": current_user.user_id,
            }
        )
        db.commit()

        row = db.execute(
            text("SELECT * FROM addresses WHERE address_id = :address_id"),
            {"address_id": address_id}
        ).mappings().first()

        return {
            "message": "Address updated successfully",
            "address": _format_address(dict(row)) if row else None
        }

    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        print("ADDRESS UPDATE ERROR:", repr(e))
        raise HTTPException(
            status_code=500,
            detail="Could not update address"
        )


# ── PUT /addresses/{address_id}/default ──────────────────────────────────────

@router.put("/{address_id}/default")
def set_default_address(
    address_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    try:
        existing = db.execute(
            text("SELECT address_id FROM addresses WHERE address_id = :address_id AND user_id = :user_id"),
            {"address_id": address_id, "user_id": current_user.user_id}
        ).fetchone()

        if not existing:
            raise HTTPException(status_code=404, detail="Address not found")

        db.execute(
            text("UPDATE addresses SET is_default = 0 WHERE user_id = :user_id"),
            {"user_id": current_user.user_id}
        )
        db.execute(
            text("UPDATE addresses SET is_default = 1 WHERE address_id = :address_id AND user_id = :user_id"),
            {"address_id": address_id, "user_id": current_user.user_id}
        )
        db.commit()

        return {"message": "Default address updated successfully", "address_id": address_id}
    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        print("ADDRESS DEFAULT ERROR:", repr(e))
        raise HTTPException(status_code=500, detail="Could not set default address")


# ── DELETE /addresses/{address_id} ───────────────────────────────────────────

@router.delete("/{address_id}")
def delete_address(
    address_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    try:
        res = db.execute(
            text("DELETE FROM addresses WHERE address_id = :address_id AND user_id = :user_id"),
            {"address_id": address_id, "user_id": current_user.user_id}
        )
        db.commit()

        if res.rowcount == 0:
            raise HTTPException(status_code=404, detail="Address not found")

        return {"message": "Address deleted successfully", "address_id": address_id}
    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        print("ADDRESS DELETE ERROR:", repr(e))
        raise HTTPException(status_code=500, detail="Could not delete address")
