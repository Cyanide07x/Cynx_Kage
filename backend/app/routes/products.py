
from fastapi import APIRouter, HTTPException, Query
from sqlalchemy import text

from app.database import engine

router = APIRouter(
    prefix="/products",
    tags=["Products"]
)


@router.get("/")
def get_products(
    include_drafts: bool = Query(default=False),
    is_featured: bool | None = Query(default=None),
    is_new_arrival: bool | None = Query(default=None),
    collection: str | None = Query(default=None)
):
    try:
        query = """
            SELECT
                p.product_id,
                p.product_name,
                p.slug,
                p.description,
                p.brand,
                p.material,
                p.fit_type,
                p.care_instructions,
                p.design_category,
                p.design_name,
                p.status,
                p.is_featured,
                p.is_new_arrival,
                c.category_name,

                pv.variant_id,
                pv.sku,
                pv.size,
                pv.color,
                pv.price,
                pv.mrp,
                pv.stock_quantity,
                pv.is_active AS variant_is_active,

                pi.image_id,
                pi.image_url,
                pi.alt_text,
                pi.is_primary,
                pi.display_order

            FROM products p

            LEFT JOIN categories c
                ON p.category_id = c.category_id

            LEFT JOIN categories audience
                ON c.parent_id = audience.category_id

            LEFT JOIN product_variants pv
                ON p.product_id = pv.product_id

            LEFT JOIN product_images pi
                ON p.product_id = pi.product_id

            WHERE 1=1
        """

        params = {}

        # Collection filter
        if collection is not None:
            collection = collection.lower().strip()

            collection_filters = {
                "men": ["men", "unisex"],
                "women": ["women", "unisex"],
                "unisex": ["unisex"]
            }

            if collection not in collection_filters:
                raise HTTPException(
                    status_code=400,
                    detail="Invalid collection. Use men, women or unisex."
                )

            allowed_audiences = collection_filters[collection]

            placeholders = ", ".join(
                f":audience_{i}"
                for i in range(len(allowed_audiences))
            )

            query += f"""
                AND LOWER(COALESCE(audience.category_name, c.category_name))
                IN ({placeholders})
            """

            for i, audience_name in enumerate(allowed_audiences):
                params[f"audience_{i}"] = audience_name

        # Product status filter
        if not include_drafts:
            query += " AND p.status = 'active'"

        # Featured products filter
        if is_featured is not None:
            query += " AND p.is_featured = :is_featured"
            params["is_featured"] = is_featured

        # New arrivals filter
        if is_new_arrival is not None:
            query += " AND p.is_new_arrival = :is_new_arrival"
            params["is_new_arrival"] = is_new_arrival

        query += """
            ORDER BY
                p.sort_order ASC,
                p.product_id ASC,
                pv.variant_id ASC,
                pi.is_primary DESC,
                pi.display_order ASC,
                pi.image_id ASC
        """

        with engine.connect() as connection:
            rows = connection.execute(
                text(query),
                params
            ).mappings().all()

        products = {}

        for row in rows:
            product_id = row["product_id"]

            if product_id not in products:
                products[product_id] = {
                    "product_id": product_id,
                    "product_name": row["product_name"],
                    "slug": row["slug"],
                    "description": row["description"],
                    "brand": row["brand"],
                    "material": row["material"],
                    "fit_type": row["fit_type"],
                    "care_instructions": row["care_instructions"],
                    "design_category": row["design_category"],
                    "design_name": row["design_name"],
                    "category_name": row["category_name"],
                    "status": row["status"],
                    "is_featured": row["is_featured"],
                    "is_new_arrival": row["is_new_arrival"],
                    "variants": {},
                    "images": {}
                }

            # Add each variant only once
            if row["variant_id"] is not None:
                variant_id = row["variant_id"]

                products[product_id]["variants"][variant_id] = {
                    "variant_id": variant_id,
                    "sku": row["sku"],
                    "size": row["size"],
                    "color": row["color"],
                    "price": row["price"],
                    "mrp": row["mrp"],
                    "stock_quantity": row["stock_quantity"],
                    "is_active": row["variant_is_active"]
                }

            # Add each image only once
            if row["image_id"] is not None:
                image_id = row["image_id"]

                products[product_id]["images"][image_id] = {
                    "image_id": image_id,
                    "image_url": row["image_url"],
                    "alt_text": row["alt_text"],
                    "is_primary": row["is_primary"],
                    "display_order": row["display_order"]
                }

        # Convert dictionaries into JSON lists
        product_list = []

        for product in products.values():
            product["variants"] = list(
                product["variants"].values()
            )

            product["images"] = list(
                product["images"].values()
            )

            product_list.append(product)

        return {
            "total": len(product_list),
            "products": product_list
        }

    except HTTPException:
        raise

    except Exception as e:
        print("PRODUCT API ERROR:", repr(e))

        raise HTTPException(
            status_code=500,
            detail="Could not fetch products"
        )
