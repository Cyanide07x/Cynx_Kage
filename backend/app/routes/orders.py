import uuid
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import text
from pydantic import BaseModel, Field

from app.database import get_db
from app.dependencies.auth import get_current_user
from app.models.user import User

router = APIRouter(
    prefix="/orders",
    tags=["Orders"]
)


# ── Pydantic Request Models ──────────────────────────────────────────────────

class OrderItemPayload(BaseModel):
    variant_id: int | None = None
    product_id: int | None = None
    productId: str | None = None
    name: str
    size: str = ""
    color: str = ""
    price: float
    quantity: int = Field(default=1, ge=1)
    imageUrl: str | None = None
    image_url: str | None = None


class DeliveryAddressPayload(BaseModel):
    address_id: int | None = None
    name: str
    phone: str
    address: str
    city: str
    state: str
    pin: str


class OrderCreatePayload(BaseModel):
    items: list[OrderItemPayload]
    address: DeliveryAddressPayload
    subtotal: float
    delivery_charge: float = 0.0
    deliveryCharge: float | None = None
    total_amount: float | None = None
    totalAmount: float | None = None
    payment_method: str = "cod"
    paymentMethod: str | None = None
    coupon_code: str | None = None
    couponCode: str | None = None
    discount_amount: float = 0.0
    discountAmount: float | None = None
    customer_note: str | None = None


# ── POST /orders (Place Order) ───────────────────────────────────────────────

@router.post("", include_in_schema=False, status_code=status.HTTP_201_CREATED)
@router.post("/", status_code=status.HTTP_201_CREATED)
def place_order(
    payload: OrderCreatePayload,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    try:
        if not payload.items:
            raise HTTPException(status_code=400, detail="Cart items cannot be empty")

        # Resolve payload aliases
        shipping_fee = payload.deliveryCharge if payload.deliveryCharge is not None else (payload.delivery_charge or 0.0)
        discount = payload.discountAmount if payload.discountAmount is not None else (payload.discount_amount or 0.0)
        final_total = payload.totalAmount if payload.totalAmount is not None else payload.total_amount
        if final_total is None:
            final_total = payload.subtotal + shipping_fee - discount
        coupon = payload.couponCode or payload.coupon_code
        raw_method = (payload.paymentMethod or payload.payment_method or "cod").lower().strip()

        # Map to valid MySQL enum: 'cod', 'upi', 'card', 'net_banking', 'other'
        valid_methods = {"cod": "cod", "upi": "upi", "card": "card", "net_banking": "net_banking"}
        method = valid_methods.get(raw_method, "cod")

        # Generate unique human-readable order number: CK-YYYYMMDD-XXXXXX
        date_str = datetime.utcnow().strftime("%Y%m%d")
        unique_suffix = uuid.uuid4().hex[:6].upper()
        order_number = f"CK-{date_str}-{unique_suffix}"

        order_status = "confirmed" if method == "cod" else "pending"
        payment_status = "pending"

        # 1. Insert into orders table
        result = db.execute(
            text("""
                INSERT INTO orders (
                    order_number,
                    user_id,
                    address_id,
                    order_status,
                    payment_method,
                    payment_status,
                    subtotal,
                    shipping_fee,
                    discount_amount,
                    total_amount,
                    shipping_name,
                    shipping_phone,
                    shipping_address_line1,
                    shipping_city,
                    shipping_state,
                    shipping_postal_code,
                    shipping_country,
                    customer_note
                ) VALUES (
                    :order_number,
                    :user_id,
                    :address_id,
                    :order_status,
                    :payment_method,
                    :payment_status,
                    :subtotal,
                    :shipping_fee,
                    :discount_amount,
                    :total_amount,
                    :shipping_name,
                    :shipping_phone,
                    :shipping_address_line1,
                    :shipping_city,
                    :shipping_state,
                    :shipping_postal_code,
                    :shipping_country,
                    :customer_note
                )
            """),
            {
                "order_number": order_number,
                "user_id": current_user.user_id,
                "address_id": payload.address.address_id,
                "order_status": order_status,
                "payment_method": method,
                "payment_status": payment_status,
                "subtotal": round(payload.subtotal, 2),
                "shipping_fee": round(shipping_fee, 2),
                "discount_amount": round(discount, 2),
                "total_amount": round(final_total, 2),
                "shipping_name": payload.address.name.strip(),
                "shipping_phone": payload.address.phone.strip(),
                "shipping_address_line1": payload.address.address.strip(),
                "shipping_city": payload.address.city.strip(),
                "shipping_state": payload.address.state.strip(),
                "shipping_postal_code": payload.address.pin.strip(),
                "shipping_country": "India",
                "customer_note": payload.customer_note or (f"Coupon: {coupon}" if coupon else None),
            }
        )
        order_id = result.lastrowid

        # 2. Insert line items into order_items table
        for item in payload.items:
            # Look up SKU from product_variants if variant_id exists
            sku = None
            if item.variant_id:
                variant_row = db.execute(
                    text("SELECT sku FROM product_variants WHERE variant_id = :vid"),
                    {"vid": item.variant_id}
                ).fetchone()
                if variant_row:
                    sku = variant_row[0]

            if not sku:
                safe_name = "".join(c for c in item.name if c.isalnum() or c in "-_")[:10].upper()
                sku = f"CK-{safe_name}-{item.size}-{item.color}".strip("-")

            line_total = round(item.price * item.quantity, 2)

            db.execute(
                text("""
                    INSERT INTO order_items (
                        order_id,
                        variant_id,
                        product_name,
                        sku,
                        size,
                        color,
                        unit_price,
                        quantity,
                        line_total
                    ) VALUES (
                        :order_id,
                        :variant_id,
                        :product_name,
                        :sku,
                        :size,
                        :color,
                        :unit_price,
                        :quantity,
                        :line_total
                    )
                """),
                {
                    "order_id": order_id,
                    "variant_id": item.variant_id,
                    "product_name": item.name.strip(),
                    "sku": sku,
                    "size": item.size.strip(),
                    "color": item.color.strip(),
                    "unit_price": round(item.price, 2),
                    "quantity": item.quantity,
                    "line_total": line_total,
                }
            )

        # 3. Clear user's cart in MySQL
        db.execute(
            text("DELETE FROM cart_items WHERE user_id = :user_id"),
            {"user_id": current_user.user_id}
        )

        db.commit()

        return {
            "message": "Order placed successfully",
            "order_id": str(order_id),
            "order_number": order_number
        }

    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        print("PLACE ORDER ERROR:", repr(e))
        raise HTTPException(
            status_code=500,
            detail="Could not place order"
        )


# ── GET /orders (Order History) ──────────────────────────────────────────────

@router.get("", include_in_schema=False)
@router.get("/")
def get_user_orders(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    try:
        order_rows = db.execute(
            text("""
                SELECT *
                FROM orders
                WHERE user_id = :user_id
                ORDER BY created_at DESC
            """),
            {"user_id": current_user.user_id}
        ).mappings().all()

        orders = []

        for row in order_rows:
            order_id = row["order_id"]

            # Fetch line items for this order
            item_rows = db.execute(
                text("""
                    SELECT
                        oi.*,
                        (
                            SELECT pi.image_url
                            FROM product_variants pv
                            JOIN product_images pi ON pv.product_id = pi.product_id
                            WHERE pv.variant_id = oi.variant_id
                            ORDER BY pi.is_primary DESC, pi.display_order ASC
                            LIMIT 1
                        ) AS image_url
                    FROM order_items oi
                    WHERE oi.order_id = :order_id
                """),
                {"order_id": order_id}
            ).mappings().all()

            items = [
                {
                    "order_item_id": it["order_item_id"],
                    "variant_id": it["variant_id"],
                    "product_name": it["product_name"],
                    "name": it["product_name"],
                    "sku": it["sku"],
                    "size": it["size"],
                    "color": it["color"],
                    "price": float(it["unit_price"]),
                    "unit_price": float(it["unit_price"]),
                    "quantity": int(it["quantity"]),
                    "line_total": float(it["line_total"]),
                    "imageUrl": it.get("image_url") or "",
                    "image_url": it.get("image_url") or "",
                }
                for it in item_rows
            ]

            orders.append({
                "order_id": str(row["order_id"]),
                "orderId": str(row["order_id"]),
                "order_number": row["order_number"],
                "orderNumber": row["order_number"],
                "order_status": row["order_status"],
                "orderStatus": row["order_status"],
                "payment_method": row["payment_method"].upper(),
                "paymentMethod": row["payment_method"].upper(),
                "payment_status": row["payment_status"],
                "paymentStatus": row["payment_status"],
                "subtotal": float(row["subtotal"]),
                "deliveryCharge": float(row["shipping_fee"]),
                "shipping_fee": float(row["shipping_fee"]),
                "discountAmount": float(row["discount_amount"]),
                "discount_amount": float(row["discount_amount"]),
                "totalAmount": float(row["total_amount"]),
                "total_amount": float(row["total_amount"]),
                "createdAt": row["created_at"].isoformat() if row["created_at"] else None,
                "created_at": row["created_at"].isoformat() if row["created_at"] else None,
                "deliveryAddress": {
                    "name": row["shipping_name"],
                    "phone": row["shipping_phone"],
                    "address": row["shipping_address_line1"],
                    "city": row["shipping_city"],
                    "state": row["shipping_state"],
                    "pin": row["shipping_postal_code"],
                },
                "items": items,
            })

        return {
            "total": len(orders),
            "orders": orders
        }

    except Exception as e:
        db.rollback()
        print("GET ORDERS ERROR:", repr(e))
        raise HTTPException(
            status_code=500,
            detail="Could not fetch orders"
        )


# ── GET /orders/{order_id} ───────────────────────────────────────────────────

@router.get("/{order_id}")
def get_order_by_id(
    order_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    try:
        is_num = order_id.isdigit()
        row = db.execute(
            text("""
                SELECT *
                FROM orders
                WHERE (order_id = :num_id OR order_number = :str_id)
                  AND user_id = :user_id
            """),
            {
                "num_id": int(order_id) if is_num else -1,
                "str_id": order_id,
                "user_id": current_user.user_id
            }
        ).mappings().first()

        if not row:
            raise HTTPException(status_code=404, detail="Order not found")

        item_rows = db.execute(
            text("""
                SELECT
                    oi.*,
                    (
                        SELECT pi.image_url
                        FROM product_variants pv
                        JOIN product_images pi ON pv.product_id = pi.product_id
                        WHERE pv.variant_id = oi.variant_id
                        ORDER BY pi.is_primary DESC, pi.display_order ASC
                        LIMIT 1
                    ) AS image_url
                FROM order_items oi
                WHERE oi.order_id = :order_id
            """),
            {"order_id": row["order_id"]}
        ).mappings().all()

        items = [
            {
                "order_item_id": it["order_item_id"],
                "variant_id": it["variant_id"],
                "name": it["product_name"],
                "size": it["size"],
                "color": it["color"],
                "price": float(it["unit_price"]),
                "quantity": int(it["quantity"]),
                "line_total": float(it["line_total"]),
                "imageUrl": it.get("image_url") or "",
            }
            for it in item_rows
        ]

        return {
            "order": {
                "order_id": str(row["order_id"]),
                "orderId": str(row["order_id"]),
                "order_number": row["order_number"],
                "orderNumber": row["order_number"],
                "order_status": row["order_status"],
                "orderStatus": row["order_status"],
                "payment_method": row["payment_method"].upper(),
                "payment_status": row["payment_status"],
                "subtotal": float(row["subtotal"]),
                "shipping_fee": float(row["shipping_fee"]),
                "total_amount": float(row["total_amount"]),
                "deliveryCharge": float(row["shipping_fee"]),
                "totalAmount": float(row["total_amount"]),
                "createdAt": row["created_at"].isoformat() if row["created_at"] else None,
                "deliveryAddress": {
                    "name": row["shipping_name"],
                    "phone": row["shipping_phone"],
                    "address": row["shipping_address_line1"],
                    "city": row["shipping_city"],
                    "state": row["shipping_state"],
                    "pin": row["shipping_postal_code"],
                },
                "items": items,
            }
        }

    except HTTPException:
        raise
    except Exception as e:
        print("GET ORDER BY ID ERROR:", repr(e))
        raise HTTPException(status_code=500, detail="Could not fetch order")
