from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import text
from sqlalchemy.exc import IntegrityError
from pydantic import BaseModel, Field

from app.database import get_db
from app.dependencies.auth import get_current_user
from app.models.user import User


router = APIRouter(
    prefix="/wishlist",
    tags=["Wishlist"]
)


# REQUEST MODEL

class WishlistCreate(BaseModel):
    product_id: int = Field(gt=0)


# GET WISHLIST

@router.get("", include_in_schema=False)
@router.get("/")
def get_wishlist(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    query = text("""
        SELECT
            wi.wishlist_item_id,
            wi.added_at,

            p.product_id,
            p.product_name,
            p.slug,
            p.description,
            p.brand,

            (
                SELECT pv.price
                FROM product_variants pv
                WHERE pv.product_id = p.product_id
                  AND pv.is_active = 1
                ORDER BY pv.price ASC
                LIMIT 1
            ) AS price,

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

        FROM wishlist_items wi

        INNER JOIN products p
            ON wi.product_id = p.product_id

        WHERE wi.user_id = :user_id

        ORDER BY wi.added_at DESC
    """)

    try:
        result = db.execute(
            query,
            {"user_id": current_user.user_id}
        ).mappings().all()

        return {
            "total": len(result),
            "items": [dict(row) for row in result]
        }

    except Exception as e:
        db.rollback()
        print("WISHLIST GET ERROR:", repr(e))

        raise HTTPException(
            status_code=500,
            detail="Could not fetch wishlist"
        )


# ADD TO WISHLIST

@router.post("", include_in_schema=False, status_code=status.HTTP_201_CREATED)
@router.post("/", status_code=status.HTTP_201_CREATED)
def add_to_wishlist(
    wishlist: WishlistCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    try:
        # Check whether the product exists.
        product = db.execute(
            text("""
                SELECT product_id
                FROM products
                WHERE product_id = :product_id
            """),
            {"product_id": wishlist.product_id}
        ).fetchone()

        if not product:
            raise HTTPException(
                status_code=404,
                detail="Product not found"
            )

        # Check whether the product is already saved.
        existing_item = db.execute(
            text("""
                SELECT wishlist_item_id
                FROM wishlist_items
                WHERE user_id = :user_id
                  AND product_id = :product_id
            """),
            {
                "user_id": current_user.user_id,
                "product_id": wishlist.product_id
            }
        ).fetchone()

        if existing_item:
            return {
                "message": "Product already exists in wishlist",
                "product_id": wishlist.product_id
            }

        # Insert the product into the wishlist.
        db.execute(
            text("""
                INSERT INTO wishlist_items (
                    user_id,
                    product_id
                )
                VALUES (
                    :user_id,
                    :product_id
                )
            """),
            {
                "user_id": current_user.user_id,
                "product_id": wishlist.product_id
            }
        )

        db.commit()

        return {
            "message": "Product added to wishlist successfully",
            "product_id": wishlist.product_id
        }

    except HTTPException:
        db.rollback()
        raise

    except IntegrityError:
        db.rollback()

        # Handles a duplicate insertion caused by simultaneous requests.
        existing_item = db.execute(
            text("""
                SELECT wishlist_item_id
                FROM wishlist_items
                WHERE user_id = :user_id
                  AND product_id = :product_id
            """),
            {
                "user_id": current_user.user_id,
                "product_id": wishlist.product_id
            }
        ).fetchone()

        if existing_item:
            return {
                "message": "Product already exists in wishlist",
                "product_id": wishlist.product_id
            }

        raise HTTPException(
            status_code=500,
            detail="Could not add product to wishlist"
        )

    except Exception as e:
        db.rollback()
        print("WISHLIST POST ERROR:", repr(e))

        raise HTTPException(
            status_code=500,
            detail="Could not add product to wishlist"
        )


# REMOVE FROM WISHLIST

@router.delete("/{product_id}")
def remove_from_wishlist(
    product_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    try:
        deleted = db.execute(
            text("""
                DELETE FROM wishlist_items
                WHERE user_id = :user_id
                  AND product_id = :product_id
            """),
            {
                "user_id": current_user.user_id,
                "product_id": product_id
            }
        )
        db.commit()

        return {
            "message": "Product removed from wishlist successfully",
            "product_id": product_id
        }

    except Exception as e:
        db.rollback()
        print("WISHLIST DELETE ERROR:", repr(e))

        raise HTTPException(
            status_code=500,
            detail="Could not remove product from wishlist"
        )
