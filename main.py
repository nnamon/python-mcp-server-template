#!/usr/bin/env python3
"""
PLACEHOLDER_SERVER_DESCRIPTION

A PLACEHOLDER_SERVER_DESCRIPTION built using the FastMCP framework.

This server provides:
- Tool definitions with @mcp.tool() decorators
- Resource handling with @mcp.resource() decorators
- Pydantic models for type safety
- Session management patterns
- Error handling best practices
"""

# Import the FastMCP server object at module level for uv run mcp command
from src.mcp_server_template.server import mcp

if __name__ == "__main__":
    mcp.run()
