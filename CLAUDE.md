# Python MCP Server Template - Claude Code Instructions

## Repository Overview

This is a **template repository** for creating MCP (Model Context Protocol) servers in Python. It provides a minimal but complete foundation for building custom MCP servers using the FastMCP framework.

### Key Technologies & Dependencies
- **FastMCP**: Framework from the MCP Python SDK for rapid server development
- **uv**: Fast Python package and project manager
- **ruff**: Code formatting and linting
- **pytest**: Testing framework with async support
- **Docker**: Containerization support included
- **Pydantic**: Type safety and data validation

### Template Structure
```
├── main.py                    # Server entry point
├── src/mcp_server_template/   # Main package (needs customization)
│   ├── server.py             # MCP server implementation
│   └── models.py             # Pydantic models
├── tests/                    # Test suite
├── Makefile                  # Development commands
└── pyproject.toml           # Project configuration
```

## CRITICAL: Template Initialization Workflow

**When a user first clones or uses this template, you MUST:**

1. **Assess the user's project needs:**
   - Ask: "What will your MCP server do? (e.g., 'manage databases', 'process documents', 'integrate with APIs')"
   - Ask: "What would you like to name your package? (e.g., 'database_manager', 'document_processor')"

2. **Perform template customization:**
   - Rename `mcp_server_template` package throughout the codebase
   - Update `pyproject.toml` with new name, description, and metadata
   - Replace example tools/resources/prompts with placeholder stubs for their use case
   - Update the main.py description

3. **After customization, REWRITE THIS CLAUDE.md file:**
   - Replace template instructions with project-specific guidance
   - Include their specific MCP server purpose and functionality
   - Keep the development workflow but make it project-specific
   - Remove template initialization instructions

## Development Workflow

**CRITICAL: Always use feature branches and pull requests. NEVER commit directly to main.**

### Required Workflow
1. **Create feature branch**: `git checkout -b [type]/description-of-work`
2. **Implement changes** only on the feature branch
3. **Test functionality**: `make test` and `make lint`
4. **Commit changes** to feature branch with descriptive messages
5. **Push branch**: `git push -u origin [branch-name]`
6. **Test with running application**: Before creating a PR, ask the user to verify the changes work with `make dev`
7. **Create Pull Request**: Use `gh pr create` with proper title and description ONLY after all tests pass

### Branch Naming Convention
- `feature/` - New features or MCP primitives
- `fix/` - Bug fixes
- `refactor/` - Code refactoring
- `docs/` - Documentation updates

## Make Commands

```bash
make install    # Install dependencies with uv
make test      # Run pytest test suite
make format    # Format code with ruff
make lint      # Run ruff linting
make run       # Run MCP server in production mode
make dev       # Run MCP server with inspector for development
make clean     # Clean cache files
```

## MCP Server Development Patterns

### Basic MCP Primitives

#### Adding Tools (Functions LLMs can call)
```python
@mcp.tool()
def your_function(param: type) -> return_type:
    """Clear description of what this tool does"""
    # Implementation
    return result
```

#### Adding Resources (Data LLMs can read)
```python
@mcp.resource("your://uri/pattern")
def get_resource() -> str:
    """Description of the resource"""
    return "resource data"
```

#### Adding Prompts (Reusable templates)
```python
@mcp.prompt()
def your_prompt(context: str) -> str:
    """Description of the prompt template"""
    return f"Your prompt template with {context}"
```

### Advanced MCP Patterns

#### Input Validation with Pydantic
```python
from pydantic import BaseModel, Field

class SearchRequest(BaseModel):
    query: str = Field(min_length=1, max_length=100)
    limit: int = Field(default=10, ge=1, le=100)
    filters: list[str] = Field(default_factory=list)

@mcp.tool()
def search_items(request: SearchRequest) -> dict:
    """Search with validated input"""
    # Input is automatically validated
    return {"results": [], "query": request.query}
```

#### Progress Reporting for Long Operations
```python
from mcp.server.fastmcp import Context
import asyncio

@mcp.tool()
async def process_large_dataset(file_path: str, ctx: Context) -> dict:
    """Process data with progress updates"""
    items = load_data(file_path)  # Your data loading
    total = len(items)
    
    for i, item in enumerate(items):
        # Report progress (0.0 to 1.0)
        await ctx.report_progress(i / total)
        
        # Log progress for debugging
        ctx.info(f"Processing item {i+1}/{total}")
        
        # Process the item
        await process_item(item)
    
    return {"processed": total, "status": "complete"}
```

#### Cursor-Based Pagination
```python
import base64
from typing import Optional

@mcp.tool()
def list_items_paginated(cursor: Optional[str] = None, limit: int = 10) -> dict:
    """List items with cursor-based pagination"""
    # Decode cursor to get starting position
    start_idx = 0
    if cursor:
        try:
            start_idx = int(base64.b64decode(cursor).decode())
        except (ValueError, Exception):
            start_idx = 0
    
    # Get data slice
    all_items = get_all_items()  # Your data source
    end_idx = start_idx + limit
    page_items = all_items[start_idx:end_idx]
    
    # Generate next cursor if more data exists
    next_cursor = None
    if end_idx < len(all_items):
        next_cursor = base64.b64encode(str(end_idx).encode()).decode()
    
    return {
        "items": [item.model_dump() for item in page_items],
        "next_cursor": next_cursor,
        "total_count": len(all_items)
    }
```

#### Error Handling Pattern
```python
@mcp.tool()
def safe_operation(data: str) -> dict:
    """Tool with proper error handling"""
    try:
        result = risky_operation(data)
        return {"success": True, "result": result}
    except ValueError as e:
        return {"success": False, "error": "invalid_input", "message": str(e)}
    except Exception as e:
        return {"success": False, "error": "internal_error", "message": "Operation failed"}
```

### Image and Media Handling

#### Image Processing with FastMCP
```python
from mcp.server.fastmcp import Image
from PIL import Image as PILImage
import io

@mcp.tool()
def resize_image(image_path: str, width: int, height: int) -> Image:
    """Resize an image and return as MCP Image type"""
    with PILImage.open(image_path) as img:
        resized = img.resize((width, height), PILImage.Resampling.LANCZOS)
        
        # Convert to bytes
        img_buffer = io.BytesIO()
        resized.save(img_buffer, format='PNG')
        img_data = img_buffer.getvalue()
    
    return Image(data=img_data, format="png")

@mcp.tool()
def analyze_image(image_path: str) -> dict:
    """Analyze image and return metadata"""
    with PILImage.open(image_path) as img:
        return {
            "width": img.width,
            "height": img.height,
            "format": img.format,
            "mode": img.mode,
            "size_bytes": os.path.getsize(image_path)
        }
```

#### Base64 Image Processing
```python
import base64

@mcp.tool()
def process_base64_image(image_data: str, operation: str) -> dict:
    """Process base64 encoded image"""
    try:
        # Decode and process image
        image_bytes = base64.b64decode(image_data)
        img = PILImage.open(io.BytesIO(image_bytes))
        
        if operation == "grayscale":
            img = img.convert("L")
        elif operation == "thumbnail":
            img.thumbnail((128, 128))
        
        # Convert back to base64
        buffer = io.BytesIO()
        img.save(buffer, format='PNG')
        result_b64 = base64.b64encode(buffer.getvalue()).decode()
        
        return {"success": True, "image_data": result_b64, "format": "png"}
    except Exception as e:
        return {"success": False, "error": str(e)}
```

### Advanced Resource Patterns

#### Dynamic Resources with Validation
```python
@mcp.resource("user://{user_id}/profile")
def get_user_profile(user_id: str) -> str:
    """Get user profile with ID validation"""
    if not user_id.isdigit():
        return '{"error": "Invalid user ID format"}'
    
    user = fetch_user(int(user_id))
    if not user:
        return '{"error": "User not found"}'
    
    return user.model_dump_json()
```

#### File Resources with Security
```python
@mcp.resource("file://{file_path}")
def get_file_content(file_path: str) -> str:
    """Serve file content with security checks"""
    import os
    
    # Security: prevent path traversal
    if ".." in file_path or file_path.startswith("/"):
        return '{"error": "Invalid file path"}'
    
    if not os.path.exists(file_path):
        return '{"error": "File not found"}'
    
    with open(file_path, 'r', encoding='utf-8') as f:
        return f.read()
```

### Advanced Prompt Patterns

#### Multi-Message Prompts
```python
from mcp.server.fastmcp.prompts import base

@mcp.prompt()
def debug_session(error_message: str, code_context: str) -> list[base.Message]:
    """Create a debugging conversation prompt"""
    return [
        base.UserMessage("I'm encountering an error in my code:"),
        base.UserMessage(f"Error: {error_message}"),
        base.UserMessage(f"Code context:\n```\n{code_context}\n```"),
        base.AssistantMessage("I'll help you debug this. Let me analyze the error."),
        base.UserMessage("What are the possible causes and solutions?")
    ]
```

#### Dynamic Prompt Templates
```python
@mcp.prompt()
def code_review_prompt(code: str, focus_areas: list[str]) -> str:
    """Generate focused code review prompt"""
    focus_text = ", ".join(focus_areas) if focus_areas else "general best practices"
    
    return f"""Please review this code focusing on {focus_text}:

```
{code}
```

Provide feedback on:
- Code quality and readability
- Potential bugs or issues
- Performance considerations
- Best practices adherence
"""
```

### Session and State Management

#### Simple Session Pattern
```python
from typing import Dict, Any
import uuid

# Global session storage (use Redis/DB in production)
sessions: Dict[str, Dict[str, Any]] = {}

@mcp.tool()
def create_session(session_type: str) -> dict:
    """Create a new session"""
    session_id = str(uuid.uuid4())
    sessions[session_id] = {
        "id": session_id,
        "type": session_type,
        "created_at": datetime.now().isoformat(),
        "data": {}
    }
    return {"session_id": session_id}

@mcp.tool()
def update_session(session_id: str, key: str, value: Any) -> dict:
    """Update session data"""
    if session_id not in sessions:
        return {"success": False, "error": "Session not found"}
    
    sessions[session_id]["data"][key] = value
    return {"success": True}
```

### Database Integration

#### Safe Database Queries
```python
@mcp.tool()
async def query_database(sql: str, params: list = None) -> dict:
    """Execute database query safely"""
    # Validate SQL (implement your validation)
    if not is_safe_query(sql):
        return {"success": False, "error": "Unsafe query"}
    
    try:
        # Your database connection logic
        results = await execute_query(sql, params)
        return {"success": True, "results": results}
    except Exception as e:
        return {"success": False, "error": str(e)}
```

These patterns provide production-ready implementations for common MCP server requirements.

## Common Tasks Claude Should Help With

### Template Customization (First-time setup)
- **Package renaming**: Replace `mcp_server_template` in all files
- **Import updates**: Update all import statements
- **Metadata updates**: Update `pyproject.toml` name, description, author
- **Documentation**: Update README.md with project-specific information

### Feature Development
- **Adding new MCP tools**: Guide implementation following FastMCP patterns
- **Resource management**: Help design URI schemes and data access patterns  
- **Error handling**: Implement proper exception handling for MCP operations
- **Type safety**: Ensure Pydantic models and type hints are used correctly

### Testing & Quality
- **Writing tests**: Create pytest tests for new tools and resources
- **Code quality**: Ensure ruff formatting and linting passes
- **Integration testing**: Test MCP server with actual LLM clients

### Deployment & Docker
- **Docker configuration**: Help customize Dockerfile and docker-compose.yml
- **Environment variables**: Set up configuration management
- **Production deployment**: Guide deployment best practices

## Template-Specific File Patterns

### Files requiring package name updates:
- `src/mcp_server_template/` → `src/{new_package_name}/`
- `main.py` (import statement)
- `pyproject.toml` (multiple locations)
- `tests/test_server.py` (import statements)

### Files requiring content customization:
- `main.py` (description and purpose)
- `src/{package}/server.py` (replace example tools/resources/prompts)
- `pyproject.toml` (name, description, author, dependencies)
- `README.md` (project-specific documentation)

## Testing Strategy

- **Unit tests**: Test individual tools and resources
- **Integration tests**: Test MCP server startup and tool registration
- **Type checking**: Use mypy for static type analysis
- **Coverage**: Aim for high test coverage with pytest-cov

## Best Practices

1. **Type Safety**: Always use type hints and Pydantic models
2. **Error Handling**: Implement proper exception handling for MCP operations
3. **Documentation**: Write clear docstrings for all tools, resources, and prompts
4. **Modularity**: Organize complex servers into multiple modules
5. **Configuration**: Use environment variables for configuration
6. **Logging**: Implement proper logging for debugging and monitoring

## Docker Development

Use Docker for consistent development environments:

```bash
docker-compose up --build    # Start development environment
docker-compose exec app bash # Access container shell
```

---

**Remember**: This is a template repository. After helping the user customize it for their specific MCP server project, rewrite this CLAUDE.md to be project-specific and remove these template initialization instructions.