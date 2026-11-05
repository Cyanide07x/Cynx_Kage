
from fastapi import FastAPI
from sqlalchemy import text
from app.database import engine
from app.routes.products import router as products_router
from app.routes.categories import router as categories_router
from app.routes.auth import router as auth_router

app = FastAPI(
    title="CYNX KAGE API",
    description="Backend API for CYNX KAGE E-commerce Application",
    version="1.0.0"
)
app.include_router(products_router)
app.include_router(categories_router)
app.include_router(auth_router)


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