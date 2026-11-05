import os
from pathlib import Path

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, DeclarativeBase
from sqlalchemy.engine import URL

# Load environment variables from backend/.env if present (local development)
BASE_DIR = Path(__file__).resolve().parent.parent
env_file = BASE_DIR / ".env"
if env_file.exists():
    load_dotenv(env_file)
else:
    load_dotenv()

# Check for a direct DATABASE_URL connection string first (common in cloud providers)
RAW_DATABASE_URL = os.getenv("DATABASE_URL")

if RAW_DATABASE_URL:
    # Ensure PyMySQL driver is used if generic mysql:// URL is provided
    if RAW_DATABASE_URL.startswith("mysql://"):
        DATABASE_URL = RAW_DATABASE_URL.replace("mysql://", "mysql+pymysql://", 1)
    else:
        DATABASE_URL = RAW_DATABASE_URL
else:
    # Read individual database credentials
    DB_HOST = os.getenv("DB_HOST", "localhost")
    DB_PORT = int(os.getenv("DB_PORT", "3306"))
    DB_USER = os.getenv("DB_USER")
    DB_PASSWORD = os.getenv("DB_PASSWORD")
    DB_NAME = os.getenv("DB_NAME")

    if not all([DB_USER, DB_PASSWORD, DB_NAME]):
        raise ValueError(
            "Missing database credentials. Please provide DATABASE_URL or set DB_USER, DB_PASSWORD, and DB_NAME in your environment variables."
        )

    DATABASE_URL = URL.create(
        drivername="mysql+pymysql",
        username=DB_USER,
        password=DB_PASSWORD,
        host=DB_HOST,
        port=DB_PORT,
        database=DB_NAME,
    )

# Create SQLAlchemy engine with connection recycling suitable for serverless / cloud
engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
    pool_recycle=280,
)

# Database session
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
)

# Base class for database models
class Base(DeclarativeBase):
    pass


# Dependency for database sessions
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
