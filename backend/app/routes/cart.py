from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import text
from pydantic import BaseModel, Field

from app.database import get_db
from app.dependencies.auth import get_current_user
from app.models.user import User

router = APIRouter(
    prefix="/cart",
    tags=["Cart"]
)


# ── Pydantic Request Models ──────────────────────────────────────────────────

class CartItemCreate(BaseModel):
    variant_id: int | None = None
    product_id: int | None = None
    size: str | None = None
    color: str | None = None
    quantity: int = Field(default=1, ge=1)


class CartItemUpdate(BaseModel):
    quantity: int = Field(ge=1)


# ── Helper Query ─────────────────────────────────────────────────────────────

CART_BASE_QUERY = """
    SELECT
        ci.cart_item_id,
        ci.quantity,
        ci.added_at,
        ci.updated_at,

        pv.variant_id,
        pv.product_id,
        pv.sku,
        pv.size,
        pv.color,
        pv.price,
        pv.mrp,
        pv.stock_quantity,
        pv.is_active AS variant_is_active,

        p.product_name,
        p.slug,
        p.description,
        p.brand,

        (
            SELECT pi.image_url
            FROM product_images pi
            WHERE pi.product_id = p.product_id
            ORDER BY
                pi.is_primary DESC,
                pi.display_order ASC,
                pi.image_id ASC
            LIMIT 1
        ) AS image_url

    FROM cart_items ci
    INNER JOIN product_variants pv ON ci.variant_id = pv.variant_id
    INNER JOIN products p ON pv.product_id = p.product_id
    WHERE ci.user_id = :user_id
"""


def _format_cart_item(row: dict) -> dict:
    price = float(row["price"]) if row.get("price") is not None else 0.0
    quantity = int(row["quantity"])
    return {
        "cart_item_id": row["cart_item_id"],
        "variant_id": row["variant_id"],
        "product_id": row["product_id"],
        "name": row["product_name"],
        "slug": row["slug"],
        "description": row.get("description") or "",
        "brand": row.get("brand") or "",
        "imageUrl": row.get("image_url") or "",
        "price": price,
        "size": row["size"],
        "color": row["color"],
        "quantity": quantity,
        "line_total": round(price * quantity, 2),
        "stock_quantity": row["stock_quantity"],
        "is_active": bool(row["variant_is_active"]),
    }


# ── GET /cart ────────────────────────────────────────────────────────────────

@router.get("", include_in_schema=False)
@router.get("/")
def get_cart(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    try:
        query = CART_BASE_QUERY + " ORDER BY ci.added_at DESC"
        rows = db.execute(
            text(query),
            {"user_id": current_user.user_id}
        ).mappings().all()

        items = [_format_cart_item(dict(row)) for row in rows]
        total_quantity = sum(item["quantity"] for item in items)
        subtotal = round(sum(item["line_total"] for item in items), 2)

        return {
            "items": items,
            "total_items": total_quantity,
            "subtotal": subtotal
        }
    except Exception as e:
        db.rollback()
        print("CART GET ERROR:", repr(e))
        raise HTTPException(
            status_code=500,
            detail="Could not fetch cart items"
        )


# ── POST /cart ───────────────────────────────────────────────────────────────

@router.post("", include_in_schema=False, status_code=status.HTTP_201_CREATED)
@router.post("/", status_code=status.HTTP_201_CREATED)
def add_to_cart(
    payload: CartItemCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    try:
        variant = None

        # 1. Resolve variant by variant_id if provided
        if payload.variant_id is not None:
            variant = db.execute(
                text("""
                    SELECT variant_id, product_id, size, color, price, stock_quantity, is_active
                    FROM product_variants
                    WHERE variant_id = :variant_id
                """),
                {"variant_id": payload.variant_id}
            ).mappings().first()

        # 2. Otherwise resolve by (product_id, size, color)
        elif payload.product_id is not None and payload.size and payload.color:
            variant = db.execute(
                text("""
                    SELECT variant_id, product_id, size, color, price, stock_quantity, is_active
                    FROM product_variants
                    WHERE product_id = :product_id
                      AND LOWER(size) = LOWER(:size)
                      AND LOWER(color) = LOWER(:color)
                    LIMIT 1
                """),
                {
                    "product_id": payload.product_id,
                    "size": payload.size.strip(),
                    "color": payload.color.strip()
                }
            ).mappings().first()

        if not variant:
            raise HTTPException(
                status_code=404,
                detail="Product variant not found"
            )

        if not variant["is_active"]:
            raise HTTPException(
                status_code=400,
                detail="This product variant is currently unavailable"
            )

        resolved_variant_id = variant["variant_id"]

        # 3. Check if user already has this variant in their cart
        existing = db.execute(
            text("""
                SELECT cart_item_id, quantity
                FROM cart_items
                WHERE user_id = :user_id AND variant_id = :variant_id
            """),
            {
                "user_id": current_user.user_id,
                "variant_id": resolved_variant_id
            }
        ).mappings().first()

        if existing:
            new_qty = existing["quantity"] + payload.quantity
            db.execute(
                text("""
                    UPDATE cart_items
                    SET quantity = :qty
                    WHERE cart_item_id = :cart_item_id
                """),
                {
                    "qty": new_qty,
                    "cart_item_id": existing["cart_item_id"]
                }
            )
            cart_item_id = existing["cart_item_id"]
        else:
            insert_result = db.execute(
                text("""
                    INSERT INTO cart_items (user_id, variant_id, quantity)
                    VALUES (:user_id, :variant_id, :quantity)
                """),
                {
                    "user_id": current_user.user_id,
                    "variant_id": resolved_variant_id,
                    "quantity": payload.quantity
                }
            )
            cart_item_id = insert_result.lastrowid

        db.commit()

        # Return the updated/inserted item details
        item_row = db.execute(
            text(CART_BASE_QUERY + " AND ci.cart_item_id = :cart_item_id"),
            {
                "user_id": current_user.user_id,
                "cart_item_id": cart_item_id
            }
        ).mappings().first()

        return {
            "message": "Item added to cart successfully",
            "item": _format_cart_item(dict(item_row)) if item_row else None
        }

    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        print("CART ADD ERROR:", repr(e))
        raise HTTPException(
            status_code=500,
            detail="Could not add item to cart"
        )


# ── PUT /cart/{cart_item_id} ─────────────────────────────────────────────────

@router.put("/{cart_item_id}")
def update_cart_item_quantity(
    cart_item_id: int,
    payload: CartItemUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    try:
        item = db.execute(
            text("""
                SELECT cart_item_id
                FROM cart_items
                WHERE cart_item_id = :cart_item_id AND user_id = :user_id
            """),
            {
                "cart_item_id": cart_item_id,
                "user_id": current_user.user_id
            }
        ).fetchone()

        if not item:
            raise HTTPException(
                status_code=404,
                detail="Cart item not found"
            )

        db.execute(
            text("""
                UPDATE cart_items
                SET quantity = :quantity
                WHERE cart_item_id = :cart_item_id AND user_id = :user_id
            """),
            {
                "quantity": payload.quantity,
                "cart_item_id": cart_item_id,
                "user_id": current_user.user_id
            }
        )
        db.commit()

        return {
            "message": "Cart item quantity updated",
            "cart_item_id": cart_item_id,
            "quantity": payload.quantity
        }
    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        print("CART UPDATE ERROR:", repr(e))
        raise HTTPException(
            status_code=500,
            detail="Could not update cart item quantity"
        )


# ── DELETE /cart/clear ───────────────────────────────────────────────────────

@router.delete("/clear")
def clear_cart(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    try:
        db.execute(
            text("DELETE FROM cart_items WHERE user_id = :user_id"),
            {"user_id": current_user.user_id}
        )
        db.commit()
        return {"message": "Cart cleared successfully"}
    except Exception as e:
        db.rollback()
        print("CART CLEAR ERROR:", repr(e))
        raise HTTPException(
            status_code=500,
            detail="Could not clear cart"
        )


# ── DELETE /cart/{cart_item_id} ──────────────────────────────────────────────

@router.delete("/{cart_item_id}")
def remove_from_cart(
    cart_item_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    try:
        res = db.execute(
            text("""
                DELETE FROM cart_items
                WHERE cart_item_id = :cart_item_id AND user_id = :user_id
            """),
            {
                "cart_item_id": cart_item_id,
                "user_id": current_user.user_id
            }
        )
        db.commit()

        if res.rowcount == 0:
            raise HTTPException(
                status_code=404,
                detail="Cart item not found"
            )

        return {
            "message": "Cart item removed successfully",
            "cart_item_id": cart_item_id
        }
    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        print("CART DELETE ERROR:", repr(e))
        raise HTTPException(
            status_code=500,
            detail="Could not remove cart item"
        )
