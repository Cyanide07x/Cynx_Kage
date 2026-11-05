
from sqlalchemy import (
    Column,
    String,
    Boolean,
    DateTime,
    TIMESTAMP,
    ForeignKey,
    text,
)
from sqlalchemy.dialects.mysql import BIGINT
from sqlalchemy.sql import func

from app.database import Base


class RefreshToken(Base):
    __tablename__ = "refresh_tokens"

    token_id = Column(
        BIGINT(unsigned=True),
        primary_key=True,
        autoincrement=True
    )

    user_id = Column(
        BIGINT(unsigned=True),
        ForeignKey("users.user_id", ondelete="CASCADE"),
        nullable=False,
        index=True
    )

    token_hash = Column(
        String(255),
        unique=True,
        nullable=False
    )

    expires_at = Column(
        DateTime,
        nullable=False
    )

    is_revoked = Column(
        Boolean,
        nullable=False,
        server_default=text("0")
    )

    created_at = Column(
        TIMESTAMP,
        nullable=False,
        server_default=func.current_timestamp()
    )
