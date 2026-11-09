from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import text
from pydantic import BaseModel, Field

from app.database import get_db
from app.dependencies.auth import get_current_user
from app.models.user import User

router = APIRouter(
    prefix="/coupons",
    tags=["Coupons"]
)


# ── Request / Response Schemas ───────────────────────────────────────────────

class CouponValidatePayload(BaseModel):
    code: str
    subtotal: float = Field(ge=0)


# ── GET /coupons (List Available Coupons) ────────────────────────────────────

@router.get("", include_in_schema=False)
@router.get("/")
def get_available_coupons(db: Session = Depends(get_db)):
    """
    Fetch all active, non-expired, and non-exhausted coupons.
    Returns both snake_case and camelCase keys for Flutter client compatibility.
    """
    query = text("""
        SELECT *
        FROM coupons
        WHERE is_active = 1
          AND (expires_at IS NULL OR expires_at > NOW())
          AND (max_uses IS NULL OR used_count < max_uses)
        ORDER BY created_at DESC
    """)

    rows = db.execute(query).mappings().all()
    coupons = []

    for row in rows:
        d_type = row["discount_type"]
        d_val = float(row["discount_value"])
        min_sub = float(row["min_subtotal"]) if row["min_subtotal"] is not None else 0.0
        max_d = float(row["max_discount"]) if row["max_discount"] is not None else None

        # Build friendly description for UI cards
        if d_type == "percentage":
            desc = f"{int(d_val)}% OFF"
            if max_d:
                desc += f" up to ₹{int(max_d)}"
        else:
            desc = f"Flat ₹{int(d_val)} OFF"
        if min_sub > 0:
            desc += f" on orders above ₹{int(min_sub)}"

        coupons.append({
            "id": row["id"],
            "code": row["code"],
            "discount_type": d_type,
            "discountType": d_type,
            "discount_value": d_val,
            "discountValue": d_val,
            "min_subtotal": min_sub,
            "minSubtotal": min_sub,
            "max_discount": max_d,
            "maxDiscount": max_d,
            "description": desc,
            "expires_at": row["expires_at"].isoformat() if row["expires_at"] else None,
            "expiresAt": row["expires_at"].isoformat() if row["expires_at"] else None,
            "max_uses": row["max_uses"],
            "used_count": row["used_count"],
        })

    return {
        "success": True,
        "count": len(coupons),
        "coupons": coupons
    }


# ── POST /coupons/validate (Validate Coupon) ─────────────────────────────────

@router.post("/validate", include_in_schema=False)
@router.post("/validate/")
def validate_coupon(
    payload: CouponValidatePayload,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Validate a coupon code against the cart subtotal and calculate the discount.
    Requires user to be signed in.
    """
    code = payload.code.strip().upper()
    if not code:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Please enter a valid coupon code."
        )

    row = db.execute(
        text("SELECT * FROM coupons WHERE UPPER(code) = :code"),
        {"code": code}
    ).mappings().first()

    if not row:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="This coupon does not exist."
        )

    # 1. Check if active
    if not row["is_active"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This coupon is inactive."
        )

    # 2. Check expiry date
    if row["expires_at"] and row["expires_at"] <= datetime.utcnow():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This coupon has expired."
        )

    # 3. Check usage limit
    max_uses = row["max_uses"]
    used_count = row["used_count"] or 0
    if max_uses is not None and used_count >= max_uses:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This coupon has reached its usage limit."
        )

    # 4. Check minimum subtotal requirement
    min_subtotal = float(row["min_subtotal"]) if row["min_subtotal"] is not None else 0.0
    if payload.subtotal < min_subtotal:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Your cart subtotal must be at least ₹{int(min_subtotal)}."
        )

    # 5. Calculate discount amount
    d_type = row["discount_type"]
    d_val = float(row["discount_value"])
    max_discount = float(row["max_discount"]) if row["max_discount"] is not None else None

    if d_val <= 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This coupon has an invalid discount value."
        )

    if d_type == "percentage":
        if d_val > 100:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="This coupon has an invalid percentage."
            )
        discount = (payload.subtotal * d_val) / 100.0
        if max_discount and max_discount > 0:
            discount = min(discount, max_discount)
    elif d_type == "fixed":
        discount = d_val
    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported discount type."
        )

    # Never let discount exceed subtotal
    discount = min(discount, payload.subtotal)
    discount = round(discount, 2)
    final_subtotal = round(payload.subtotal - discount, 2)

    return {
        "valid": True,
        "code": row["code"],
        "discount_type": d_type,
        "discountType": d_type,
        "discount_value": d_val,
        "discountValue": d_val,
        "discount_amount": discount,
        "discountAmount": discount,
        "final_subtotal": final_subtotal,
        "finalSubtotal": final_subtotal,
        "message": "Coupon applied successfully.",
    }
