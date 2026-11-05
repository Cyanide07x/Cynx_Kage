
from sqlalchemy import (
    Column,
    String,
    Enum,
    Boolean,
    DateTime,
    text,
)
from sqlalchemy.dialects.mysql import BIGINT
from sqlalchemy.sql import func

from app.database import Base


class User(Base):
    __tablename__ = "users"

    user_id = Column(
        BIGINT(unsigned=True),
        primary_key=True,
        autoincrement=True
    )

    full_name = Column(
        String(100),
        nullable=False
    )

    email = Column(
        String(255),
        unique=True,
        nullable=False,
        index=False
    )

    password_hash = Column(
        String(255),
        nullable=False
    )

    phone = Column(
        String(20),
        unique=True,
        nullable=True
    )

    role = Column(
        Enum("customer", "admin", name="user_role"),
        nullable=False,
        server_default="customer"
    )

    is_active = Column(
        Boolean,
        nullable=False,
        server_default=text("1")
    )

    created_at = Column(
        DateTime,
        nullable=False,
        server_default=func.current_timestamp()
    )

    updated_at = Column(
        DateTime,
        nullable=False,
        server_default=func.current_timestamp(),
        onupdate=func.current_timestamp()
    )

    # Retained because this column currently exists in MySQL.
    # It is not used by our new authentication system.
    firebase_uid = Column(
        String(128),
        unique=True,
        nullable=True
    )
