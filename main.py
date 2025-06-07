#!/usr/bin/env python3
"""
Python MCP Server Template

A template MCP server built using the FastMCP framework from the MCP Python SDK.
Replace this description and the package name with your specific use case.

This template demonstrates:
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
