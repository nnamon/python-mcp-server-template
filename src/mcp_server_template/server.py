"""
PLACEHOLDER_SERVER_DESCRIPTION Implementation

A PLACEHOLDER_SERVER_DESCRIPTION demonstrating the three core MCP primitives:
- Tools: Functions that can be called by the LLM
- Resources: Data that can be read by the LLM
- Prompts: Reusable prompt templates
"""

from mcp.server.fastmcp import FastMCP

# Initialize the FastMCP server
mcp = FastMCP("PLACEHOLDER_SERVER_NAME")


@mcp.tool()
def add_numbers(a: int, b: int) -> int:
    """Add two numbers together"""
    return a + b


@mcp.tool()
def echo_message(message: str) -> str:
    """Echo back a message"""
    return f"You said: {message}"


@mcp.resource("config://app")
def get_config() -> str:
    """Get application configuration"""
    return "This is the application configuration data"


@mcp.resource("greeting://{name}")
def get_greeting(name: str) -> str:
    """Get a personalized greeting"""
    return f"Hello, {name}! Welcome to the MCP server."


@mcp.prompt()
def review_code(code: str) -> str:
    """Create a prompt for code review"""
    return f"Please review this code and provide feedback:\n\n{code}"


@mcp.prompt()
def explain_concept(concept: str) -> str:
    """Create a prompt to explain a concept"""
    return f"Please explain the concept of '{concept}' in simple terms with examples."
