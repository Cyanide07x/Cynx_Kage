
from fastapi import APIRouter, HTTPException
from sqlalchemy import text

from app.database import engine

router = APIRouter(
    prefix="/categories",
    tags=["Categories"]
)


@router.get("/")
def get_categories():
    try:
        query = """
            SELECT
                category_id,
                category_name,
                slug,
                parent_id
            FROM categories
            ORDER BY
                parent_id IS NOT NULL ASC,
                parent_id ASC,
                category_id ASC
        """

        with engine.connect() as connection:
            rows = connection.execute(
                text(query)
            ).mappings().all()

        categories = [
            {
                "category_id": row["category_id"],
                "category_name": row["category_name"],
                "slug": row["slug"],
                "parent_id": row["parent_id"]
            }
            for row in rows
        ]

        return {
            "total": len(categories),
            "categories": categories
        }

    except Exception as e:
        print("CATEGORY API ERROR:", repr(e))

        raise HTTPException(
            status_code=500,
            detail="Could not fetch categories"
        )
