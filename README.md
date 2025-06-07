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
   git clone <this-repo> your-mcp-server
   cd your-mcp-server
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

Follow these steps to adapt the template for your specific use case:

### 1. Update Project Metadata

Edit `pyproject.toml`:
```toml
[project]
name = "your-mcp-server-name"
description = "Your server description"
```

Also update the hatch build configuration:
```toml
[tool.hatch.build.targets.wheel]
packages = ["src/your_package_name"]  # Change from mcp_server_template
```

### 2. Rename the Package

Replace `mcp_server_template` throughout the codebase:

```bash
# Rename the package directory
mv src/mcp_server_template src/your_package_name

# Update import in main.py
# Change: from src.mcp_server_template.server import mcp
# To:     from src.your_package_name.server import mcp

# Update import in tests/test_server.py
# Change: from src.mcp_server_template.server import (...)
# To:     from src.your_package_name.server import (...)
```

### 3. Replace the Example Tools

Edit `src/your_package_name/server.py`:

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

Edit `src/your_package_name/models.py`:
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
    "your-server-name": {
      "command": "uv",
      "args": ["run", "mcp", "run", "main.py"],
      "cwd": "/path/to/your-mcp-server"
    }
  }
}
```

### Docker Configuration

For containerized deployments, configure your MCP client to use the Docker container:

```json
{
  "mcpServers": {
    "your-server-name": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "--name", "your-mcp-server",
        "your-mcp-server:latest"
      ]
    }
  }
}
```

**Important Docker Notes:**
- The `--rm` flag automatically removes the container when it exits
- The `-i` flag keeps STDIN open for MCP communication
- The `--name` flag assigns a name to the container for easier management
- Build the image first with: `docker build -t your-mcp-server:latest .`

## Docker Usage

### Build the Image
```bash
docker build -t your-mcp-server:latest .
```

### Development
```bash
docker-compose up mcp-server-dev
```

### Production
```bash
docker-compose up mcp-server-prod
```

### Manual Docker Run
```bash
# Run the server container directly
docker run --rm -i your-mcp-server:latest
```

## HTTP Streaming Configuration

### Prerequisites

Add HTTP dependencies to `pyproject.toml`:
```toml
dependencies = [
    # ... existing dependencies
    "fastapi>=0.104.0",
    "uvicorn>=0.24.0"
]
```

Install:
```bash
uv add fastapi uvicorn
```

### HTTP Server Setup

Create `http_server.py`:
```python
import asyncio
from fastapi import FastAPI, WebSocket
from mcp.server.session import ServerSession
from mcp.server.stdio import stdio_server
from src.mcp_server_template.server import mcp

app = FastAPI(title="MCP Server HTTP API")

@app.websocket("/mcp")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    
    async def read_stream():
        while True:
            data = await websocket.receive_text()
            yield data.encode()
    
    async def write_stream(data):
        await websocket.send_text(data.decode())
    
    async with stdio_server() as (read_stream, write_stream):
        session = ServerSession(mcp, read_stream, write_stream)
        await session.run()

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

### Client Configuration

Configure your MCP client for WebSocket transport:
```json
{
  "mcpServers": {
    "your-server-name": {
      "transport": {
        "type": "websocket",
        "url": "ws://localhost:8000/mcp"
      }
    }
  }
}
```

### Docker HTTP Setup

Update `Dockerfile`:
```dockerfile
# Add after existing content
EXPOSE 8000
CMD ["uvicorn", "http_server:app", "--host", "0.0.0.0", "--port", "8000"]
```

Update `docker-compose.yml`:
```yaml
version: '3.8'
services:
  mcp-server-http:
    build: .
    ports:
      - "8000:8000"
    command: ["uvicorn", "http_server:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Running

Local development:
```bash
uvicorn http_server:app --host 0.0.0.0 --port 8000 --reload
```

Docker:
```bash
docker build -t your-mcp-server:latest .
docker run -p 8000:8000 your-mcp-server:latest
```

Production:
```bash
uvicorn http_server:app --host 0.0.0.0 --port 8000 --workers 4
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