# Python MCP Server Template

A minimal template for creating MCP (Model Context Protocol) servers in Python using the FastMCP framework.

## Overview

This template provides a clean, simple starting point for building MCP servers. It demonstrates the three core MCP primitives with minimal examples that you can easily customize for your specific use case.

## Features

- **Tools**: 2 example tools using `@mcp.tool()` decorators
- **Resources**: 2 example resources with `@mcp.resource()` decorators
- **Prompts**: 2 example prompts using `@mcp.prompt()` decorators
- **Type Safety**: Pydantic models for validation
- **Testing**: Basic test suite covering all functionality
- **Docker Support**: Ready-to-use containerization
- **Development Tools**: Modern tooling with uv, ruff, and pytest

## Quick Start

### Prerequisites

- Python 3.12+
- [uv](https://github.com/astral-sh/uv) (recommended)

### Installation

1. **Clone this template**:
   ```bash
   git clone <this-repo> PLACEHOLDER_PROJECT_NAME
   cd PLACEHOLDER_PROJECT_NAME
   ```

2. **Install dependencies**:
   ```bash
   make install
   ```

3. **Run the server**:
   ```bash
   make run
   ```

4. **Test the installation**:
   ```bash
   make test
   ```

## Project Structure

```
src/mcp_server_template/
├── __init__.py              # Package initialization
├── server.py                # Main MCP server with tools, resources, and prompts
└── models.py                # Example Pydantic data models
tests/
└── test_server.py           # Basic test suite
main.py                      # Entry point for the server
pyproject.toml              # Project configuration and dependencies
Makefile                    # Development commands
Dockerfile                  # Container configuration
docker-compose.yml          # Docker orchestration
```

## What's Included

### Tools
- `add_numbers(a: int, b: int) -> int`: Add two numbers together
- `echo_message(message: str) -> str`: Echo back a message

### Resources
- `config://app`: Get application configuration
- `greeting://{name}`: Get a personalized greeting for any name

### Prompts
- `review_code(code: str)`: Generate a code review prompt
- `explain_concept(concept: str)`: Generate an explanation prompt

### Data Models
- `ExampleModel`: A basic Pydantic model with id, name, description, and timestamp

## Customization Guide

### Quick Start with Slash Command

If you're using Claude Code, the fastest way to customize this template is with the built-in slash command:

```
/project:new-project
```

This command will automatically:
- Detect if this is a spawned project
- Guide you through project setup questions
- Replace all placeholders with your values
- Rename packages and update imports
- Verify everything builds correctly

### Manual Customization

If you prefer to customize manually, follow these steps to adapt the template for your specific use case:

### 1. Update Project Metadata

Edit `pyproject.toml`:
```toml
[project]
name = "placeholder-mcp-server-name"
description = "PLACEHOLDER_SERVER_DESCRIPTION"
```

Also update the hatch build configuration:
```toml
[tool.hatch.build.targets.wheel]
packages = ["src/placeholder_package_name"]  # Change from mcp_server_template
```

### 2. Rename the Package

Replace `mcp_server_template` throughout the codebase:

```bash
# Rename the package directory
mv src/mcp_server_template src/placeholder_package_name

# Update import in main.py
# Change: from src.mcp_server_template.server import mcp
# To:     from src.placeholder_package_name.server import mcp

# Update import in tests/test_server.py
# Change: from src.mcp_server_template.server import (...)
# To:     from src.placeholder_package_name.server import (...)
```

### 3. Replace the Example Tools

Edit `src/placeholder_package_name/server.py`:

```python
@mcp.tool()
def your_custom_tool(param: str) -> dict:
    """Your tool description"""
    # Replace with your logic
    return {"result": f"Processed: {param}"}
```

### 4. Replace the Example Resources

```python
@mcp.resource("your-scheme://path")
def your_resource() -> str:
    """Your resource description"""
    # Replace with your data
    return "Your resource content"
```

### 5. Replace the Example Prompts

```python
@mcp.prompt()
def your_prompt(input_data: str) -> str:
    """Your prompt description"""
    # Replace with your prompt template
    return f"Your prompt template with {input_data}"
```

### 6. Update Data Models

Edit `src/placeholder_package_name/models.py`:
```python
class YourDataModel(BaseModel):
    """Your domain-specific model"""
    id: str
    your_field: str
    # Add your specific fields
```

### 7. Update Tests

Edit `tests/test_server.py` to test your new functionality:
```python
def test_your_custom_tool():
    result = your_custom_tool("test input")
    assert result["result"] == "Processed: test input"
```

### 8. Update Docker Configuration

Edit the Docker image name in your build commands and client configuration:

```bash
# Update the image name in build commands
docker build -t your-mcp-server:latest .  # Change from mcp-server-template
```

Update MCP client configuration with your server name:
```json
{
  "mcpServers": {
    "your-server-name": {  // Change from "mcp-server-template"
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--name", "your-mcp-server",  // Change container name
        "your-mcp-server:latest"     // Change image name
      ]
    }
  }
}
```

## Development Commands

```bash
# Install dependencies
make install

# Run tests
make test

# Format code
make format

# Run linting
make lint

# Run server
make run

# Run server with inspector (for debugging)
make dev

# Clean cache files
make clean
```

## MCP Client Configuration

### Local Development

Configure your MCP client to use this server locally:

```json
{
  "mcpServers": {
    "PLACEHOLDER_SERVER_NAME": {
      "command": "uv",
      "args": ["run", "mcp", "run", "main.py"],
      "cwd": "/path/to/PLACEHOLDER_PROJECT_NAME"
    }
  }
}
```

### Docker Configuration

For containerized deployments, configure your MCP client to use the Docker container:

```json
{
  "mcpServers": {
    "PLACEHOLDER_SERVER_NAME": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "--name", "placeholder-mcp-server",
        "placeholder-mcp-server:latest"
      ]
    }
  }
}
```

**Important Docker Notes:**
- The `--rm` flag automatically removes the container when it exits
- The `-i` flag keeps STDIN open for MCP communication
- The `--name` flag assigns a name to the container for easier management
- Build the image first with: `docker build -t placeholder-mcp-server:latest .`

## Docker Usage

### Build the Image
```bash
docker build -t placeholder-mcp-server:latest .
```

### Development
```bash
docker-compose up PLACEHOLDER_SERVER_NAME-dev
```

### Production
```bash
docker-compose up PLACEHOLDER_SERVER_NAME-prod
```

### Manual Docker Run
```bash
# Run the server container directly
docker run --rm -i placeholder-mcp-server:latest
```

## Server-Sent Events (SSE) Configuration

### Local SSE Setup

Run the MCP server with SSE transport:
```bash
uv run mcp run main.py --transport sse --port 8000
```

### Client Configuration

Configure your MCP client for SSE transport:
```json
{
  "mcpServers": {
    "PLACEHOLDER_SERVER_NAME": {
      "transport": {
        "type": "sse",
        "url": "http://localhost:8000/sse"
      }
    }
  }
}
```

### Docker SSE Setup

Use the provided SSE service in `docker-compose.yml`:
```bash
docker-compose up PLACEHOLDER_SERVER_NAME-sse
```

Or build and run directly:
```bash
docker build -t placeholder-mcp-server:latest .
docker run -p 8000:8000 placeholder-mcp-server:latest
```

## Testing

Run the test suite:
```bash
make test

# Or with pytest directly
uv run pytest -v
```

The tests cover:
- Tool functionality
- Resource access
- Prompt generation
- Basic error handling

## Next Steps

1. **Replace the examples** with your domain-specific tools, resources, and prompts
2. **Add your business logic** to the tool implementations
3. **Create meaningful resources** that provide value to LLM interactions
4. **Design useful prompts** for your specific use case
5. **Expand the test suite** to cover your custom functionality
6. **Update documentation** to reflect your server's capabilities

## Support

- [MCP Documentation](https://spec.modelcontextprotocol.io/)
- [FastMCP Framework](https://github.com/pydantic/fastmcp)
- [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk)

## License

MIT License - see LICENSE file for details.
