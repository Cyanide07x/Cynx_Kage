from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text
from app.database import engine
from app.routes.products import router as products_router
from app.routes.categories import router as categories_router
from app.routes.auth import router as auth_router
from app.routes.wishlist import router as wishlist_router
from app.routes.cart import router as cart_router
from app.routes.addresses import router as addresses_router
from app.routes.orders import router as orders_router
from app.routes import coupons

app = FastAPI(
    title="CYNX KAGE API",
    description="Backend API for CYNX KAGE E-commerce Application",
    version="1.0.0"
)

# Enable CORS for cross-origin frontend requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(products_router)
app.include_router(categories_router)
app.include_router(auth_router)
app.include_router(wishlist_router)
app.include_router(cart_router)
app.include_router(addresses_router)
app.include_router(orders_router)
app.include_router (coupons.router)


@app.get("/")
def home():
    return {
        "message": "Welcome to CYNX KAGE API",
        "status": "Running successfully"
    }


@app.get("/health")
def health_check():
    return {
        "status": "healthy"
    }


@app.get("/db-health")
def database_health():
    try:
        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))

        return {
            "status": "connected",
            "database": "cynx_kage"
        }

    except Exception as e:
        return {
            "status": "error",
            "message": str(e)
        }
