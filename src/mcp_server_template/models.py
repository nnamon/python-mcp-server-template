"""
Data models for the MCP server template.

This module contains example Pydantic models. In a real implementation,
replace these with your domain-specific models.
"""

from datetime import datetime

from pydantic import BaseModel, Field


class ExampleModel(BaseModel):
    """
    Example data model - replace with your domain-specific models.
    """

    id: str = Field(description="Unique identifier")
    name: str = Field(description="Display name")
    description: str | None = Field(default=None, description="Optional description")
    created_at: datetime = Field(
        default_factory=datetime.now, description="Creation timestamp"
    )
