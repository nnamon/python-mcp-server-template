# MCP Python SDK Typing Best Practices

A comprehensive guide to type-safe development with the Model Context Protocol (MCP) Python SDK.

## Table of Contents

1. [Overview](#overview)
2. [Core Typing Principles](#core-typing-principles)
3. [Pagination Patterns](#pagination-patterns)
4. [Rich Content Types](#rich-content-types)
5. [Error Handling](#error-handling)
6. [Advanced Typing Features](#advanced-typing-features)
7. [Validation Patterns](#validation-patterns)
8. [Progress Reporting](#progress-reporting)
9. [Type Safety Checklist](#type-safety-checklist)

## Overview

The MCP Python SDK leverages Pydantic V2 and advanced Python typing features to provide robust type safety and validation. This guide demonstrates best practices for creating type-safe MCP servers that are maintainable, reliable, and protocol-compliant.

### Key Technologies

- **Pydantic V2**: Data validation and serialization
- **Python 3.12+ Type Hints**: Advanced typing features
- **Generic Types**: Reusable, type-safe components
- **Union Types**: Flexible content handling
- **Annotated Types**: Enhanced validation

## Core Typing Principles

### 1. Always Use ConfigDict with Extra Allow

MCP protocol requires flexibility for future extensions. Always include `extra="allow"` in your models:

```python
from pydantic import BaseModel, ConfigDict

class MyModel(BaseModel):
    """MCP-compatible model with extensibility"""
    name: str
    description: str | None = None
    
    model_config = ConfigDict(extra="allow")
```

### 2. Prefer Union Types Over Any

Use specific union types instead of `Any` for better type safety:

```python
from typing import Union

# Good: Specific union type
ContentType = Union[str, dict, list[str]]

# Avoid: Too permissive
ContentType = Any
```

### 3. Use Annotated Types for Validation

Leverage `Annotated` types with field constraints:

```python
from typing import Annotated
from pydantic import Field

# Type aliases with validation
NonEmptyStr = Annotated[str, Field(min_length=1)]
Priority = Annotated[float, Field(ge=0.0, le=1.0)]
PositiveInt = Annotated[int, Field(gt=0)]

class ToolParams(BaseModel):
    name: NonEmptyStr
    priority: Priority = 0.5
    max_results: PositiveInt = 10
```

## Pagination Patterns

### Cursor-Based Pagination

MCP uses cursor-based pagination for efficient data traversal:

```python
from typing import Optional
import base64

@mcp.tool()
def list_items_paginated(
    cursor: Optional[str] = None, 
    limit: int = 10
) -> dict:
    """List items with proper cursor-based pagination"""
    
    # Decode cursor safely
    start_idx = 0
    if cursor:
        try:
            start_idx = int(base64.b64decode(cursor).decode())
        except (ValueError, UnicodeDecodeError):
            start_idx = 0  # Invalid cursor - start from beginning
    
    # Get data slice
    all_items = get_all_items()
    end_idx = start_idx + limit
    page_items = all_items[start_idx:end_idx]
    
    # Generate next cursor following MCP standard
    next_cursor = None
    if end_idx < len(all_items):
        next_cursor = base64.b64encode(str(end_idx).encode()).decode()
    
    return {
        "items": [item.model_dump() for item in page_items],
        "nextCursor": next_cursor,  # MCP standard field name
        "total_count": len(all_items)
    }
```

### Generic Pagination Helper

Create reusable pagination utilities:

```python
from typing import TypeVar, Generic
from pydantic import BaseModel

T = TypeVar('T')

class PaginatedResponse(BaseModel, Generic[T]):
    """Generic paginated response following MCP patterns"""
    items: list[T]
    nextCursor: str | None = None
    total_count: int | None = None
    
    model_config = ConfigDict(extra="allow")

def paginate_data(
    all_items: list[T], 
    cursor: str | None = None, 
    page_size: int = 50
) -> PaginatedResponse[T]:
    """Generic pagination helper"""
    start_idx = decode_cursor(cursor) if cursor else 0
    end_idx = start_idx + page_size
    
    page_items = all_items[start_idx:end_idx]
    next_cursor = encode_cursor(end_idx) if end_idx < len(all_items) else None
    
    return PaginatedResponse(
        items=page_items,
        nextCursor=next_cursor,
        total_count=len(all_items)
    )
```

## Rich Content Types

### Content Type Hierarchy

MCP supports various content types with proper type safety:

```python
from typing import Literal, Union
from pydantic import BaseModel

class TextContent(BaseModel):
    """Text content with optional annotations"""
    type: Literal["text"]
    text: str
    annotations: dict | None = None
    
    model_config = ConfigDict(extra="allow")

class ImageContent(BaseModel):
    """Image content with base64 data"""
    type: Literal["image"]
    data: str  # base64-encoded
    mimeType: str
    annotations: dict | None = None
    
    model_config = ConfigDict(extra="allow")

class AudioContent(BaseModel):
    """Audio content with base64 data"""
    type: Literal["audio"]
    data: str  # base64-encoded
    mimeType: str
    annotations: dict | None = None
    
    model_config = ConfigDict(extra="allow")

# Union type for all content types
ContentType = Union[TextContent, ImageContent, AudioContent]
```

### Type-Safe Content Creation

Create helper functions for content generation:

```python
import base64
import mimetypes

def create_text_content(text: str, priority: float = 0.5) -> TextContent:
    """Create properly typed text content"""
    annotations = {"priority": priority} if priority != 0.5 else None
    return TextContent(
        type="text",
        text=text,
        annotations=annotations
    )

def create_image_content(image_data: bytes, mime_type: str) -> ImageContent:
    """Create properly typed image content"""
    return ImageContent(
        type="image",
        data=base64.b64encode(image_data).decode(),
        mimeType=mime_type
    )

@mcp.tool()
def process_file_with_rich_content(file_path: str) -> dict:
    """Tool returning properly typed rich content"""
    try:
        mime_type, _ = mimetypes.guess_type(file_path)
        
        with open(file_path, 'rb') as f:
            file_data = f.read()
        
        # Return appropriate content type based on file
        if mime_type and mime_type.startswith('text/'):
            content = create_text_content(file_data.decode('utf-8'))
        elif mime_type and mime_type.startswith('image/'):
            content = create_image_content(file_data, mime_type)
        else:
            content = create_text_content(f"Binary file: {file_path}")
        
        return {
            "success": True,
            "content": content.model_dump()
        }
    except Exception as e:
        return {"success": False, "error": str(e)}
```

### Multi-Content Responses

Handle multiple content types in a single response:

```python
@mcp.tool()
def analyze_document_with_chart(doc_path: str) -> dict:
    """Tool returning multiple content types"""
    try:
        # Generate analysis
        analysis_text = perform_document_analysis(doc_path)
        chart_image = generate_analysis_chart(doc_path)
        
        content_list = [
            create_text_content(f"Analysis complete for {doc_path}"),
            create_text_content(analysis_text),
            create_image_content(chart_image, "image/png")
        ]
        
        return {
            "success": True,
            "content": [item.model_dump() for item in content_list],
            "isError": False
        }
    except Exception as e:
        error_content = create_text_content(f"Error: {str(e)}")
        return {
            "success": False,
            "content": [error_content.model_dump()],
            "isError": True
        }
```

## Error Handling

### Standardized Error Types

Create consistent error handling patterns:

```python
from typing import Literal, TypedDict, Union, Any

# Standard MCP error codes
PARSE_ERROR = -32700
INVALID_REQUEST = -32600
METHOD_NOT_FOUND = -32601
INVALID_PARAMS = -32602
INTERNAL_ERROR = -32603

class ErrorResponse(TypedDict):
    """Standardized error response"""
    success: Literal[False]
    error: str
    error_code: int
    details: dict[str, Any] | None

class SuccessResponse(TypedDict):
    """Standardized success response"""
    success: Literal[True]
    data: Any

ToolResponse = Union[SuccessResponse, ErrorResponse]

def create_error_response(
    message: str, 
    code: int = INTERNAL_ERROR, 
    details: dict[str, Any] | None = None
) -> ErrorResponse:
    """Create standardized error response"""
    return ErrorResponse(
        success=False,
        error=message,
        error_code=code,
        details=details
    )

def create_success_response(data: Any) -> SuccessResponse:
    """Create standardized success response"""
    return SuccessResponse(success=True, data=data)
```

### Comprehensive Error Handling

Implement robust error handling in tools:

```python
@mcp.tool()
def safe_file_operation(file_path: str, operation: str) -> ToolResponse:
    """Tool with comprehensive error handling"""
    try:
        # Input validation
        if not file_path or not operation:
            return create_error_response(
                "Missing required parameters",
                INVALID_PARAMS,
                {
                    "missing": [
                        param for param in ["file_path", "operation"] 
                        if not locals()[param]
                    ]
                }
            )
        
        # Perform operation with specific error handling
        result = perform_file_operation(file_path, operation)
        return create_success_response(result)
        
    except FileNotFoundError:
        return create_error_response(
            f"File not found: {file_path}",
            404,  # Custom application error code
            {"file_path": file_path, "operation": operation}
        )
    except PermissionError:
        return create_error_response(
            f"Permission denied: {file_path}",
            403,
            {"file_path": file_path, "operation": operation}
        )
    except ValueError as e:
        return create_error_response(
            "Invalid operation parameters",
            INVALID_PARAMS,
            {"message": str(e), "operation": operation}
        )
    except Exception as e:
        return create_error_response(
            "Internal server error",
            INTERNAL_ERROR,
            {
                "exception_type": type(e).__name__, 
                "message": str(e),
                "operation": operation
            }
        )
```

## Advanced Typing Features

### Generic Type Patterns

Create reusable, type-safe components:

```python
from typing import TypeVar, Generic, Protocol
from abc import abstractmethod

# Type variables
T = TypeVar('T')
RequestT = TypeVar('RequestT', bound=BaseModel)
ResponseT = TypeVar('ResponseT', bound=BaseModel)

# Protocol for processors
class Processor(Protocol[T]):
    @abstractmethod
    def process(self, data: T) -> T: ...

# Generic handler pattern
class TypedHandler(Generic[RequestT, ResponseT]):
    """Generic handler with full type safety"""
    
    def __init__(
        self, 
        request_type: type[RequestT], 
        response_type: type[ResponseT]
    ):
        self.request_type = request_type
        self.response_type = response_type
    
    def handle(self, raw_params: dict) -> ResponseT:
        # Type-safe parameter validation
        validated_params = self.request_type.model_validate(raw_params)
        result_data = self.process(validated_params)
        return self.response_type.model_validate(result_data)
    
    @abstractmethod
    def process(self, params: RequestT) -> dict[str, Any]:
        """Override this method with your processing logic"""
        pass
```

### Union Type Safety

Handle union types safely with pattern matching:

```python
def process_content_safely(content: ContentType) -> str:
    """Type-safe content processing using pattern matching"""
    match content.type:
        case "text":
            # TypeScript-style type narrowing works here
            return f"Text content: {content.text[:100]}..."
        case "image":
            return f"Image: {content.mimeType}, {len(content.data)} bytes"
        case "audio":
            return f"Audio: {content.mimeType}, {len(content.data)} bytes"
        case _:
            # This should never happen with proper typing
            return "Unknown content type"

# Alternative: Using isinstance for older Python versions
def process_content_isinstance(content: ContentType) -> str:
    """Type-safe content processing using isinstance"""
    if isinstance(content, TextContent):
        return f"Text content: {content.text[:100]}..."
    elif isinstance(content, ImageContent):
        return f"Image: {content.mimeType}, {len(content.data)} bytes"
    elif isinstance(content, AudioContent):
        return f"Audio: {content.mimeType}, {len(content.data)} bytes"
    else:
        return "Unknown content type"
```

## Validation Patterns

### Advanced Field Validation

Use Pydantic's validation features extensively:

```python
from pydantic import validator, root_validator, Field
from typing import Any

class AdvancedResourceModel(BaseModel):
    """Resource model with comprehensive validation"""
    uri: str
    name: str
    size: int | None = None
    metadata: dict[str, Any] = Field(default_factory=dict)
    tags: list[str] = Field(default_factory=list)
    
    @validator('uri')
    def validate_uri(cls, v):
        """Custom URI validation"""
        allowed_schemes = ['http://', 'https://', 'file://', 'mcp://']
        if not any(v.startswith(scheme) for scheme in allowed_schemes):
            raise ValueError(f'URI must start with one of: {allowed_schemes}')
        return v
    
    @validator('name')
    def validate_name(cls, v):
        """Ensure name is reasonable"""
        if not v.strip():
            raise ValueError('Name cannot be empty')
        if len(v) > 255:
            raise ValueError('Name too long (max 255 characters)')
        return v.strip()
    
    @validator('tags')
    def validate_tags(cls, v):
        """Validate tag list"""
        if len(v) > 10:
            raise ValueError('Maximum 10 tags allowed')
        # Remove duplicates while preserving order
        seen = set()
        return [tag for tag in v if not (tag in seen or seen.add(tag))]
    
    @root_validator
    def validate_consistency(cls, values):
        """Cross-field validation"""
        uri = values.get('uri')
        size = values.get('size')
        
        # Example: file:// URIs should have size information
        if uri and uri.startswith('file://') and size is None:
            # Could determine file size automatically
            values['size'] = get_file_size(uri)
        
        return values
    
    model_config = ConfigDict(extra="allow")
```

### Custom Validators

Create reusable validation patterns:

```python
from typing import Callable, TypeVar
from pydantic import validator

T = TypeVar('T')

def length_validator(
    min_length: int = 0, 
    max_length: int | None = None
) -> Callable[[type, str], str]:
    """Factory for creating length validators"""
    def validate_length(cls, v: str) -> str:
        if len(v) < min_length:
            raise ValueError(f'Minimum length is {min_length}')
        if max_length and len(v) > max_length:
            raise ValueError(f'Maximum length is {max_length}')
        return v
    return validate_length

def range_validator(
    min_val: float | int, 
    max_val: float | int
) -> Callable[[type, T], T]:
    """Factory for creating range validators"""
    def validate_range(cls, v: T) -> T:
        if v < min_val or v > max_val:
            raise ValueError(f'Value must be between {min_val} and {max_val}')
        return v
    return validate_range

class ValidatedParams(BaseModel):
    """Example using custom validators"""
    name: str
    description: str
    priority: float
    
    # Apply custom validators
    _validate_name = validator('name', allow_reuse=True)(
        length_validator(min_length=1, max_length=100)
    )
    _validate_description = validator('description', allow_reuse=True)(
        length_validator(max_length=500)
    )
    _validate_priority = validator('priority', allow_reuse=True)(
        range_validator(0.0, 1.0)
    )
```

## Progress Reporting

### Type-Safe Progress Reporting

Implement progress reporting with proper typing:

```python
from typing import AsyncContextManager
from contextlib import asynccontextmanager

class ProgressReporter:
    """Type-safe progress reporter for long-running operations"""
    
    def __init__(self, token: str, total: float | None = None):
        self.token = token
        self.total = total
        self.current = 0.0
    
    async def report(self, progress: float, message: str | None = None):
        """Report progress with validation"""
        if self.total and progress > self.total:
            raise ValueError(f"Progress {progress} exceeds total {self.total}")
        
        self.current = progress
        # Implementation would send actual progress notification
        await self._send_progress_notification({
            "progressToken": self.token,
            "progress": progress,
            "total": self.total,
            "message": message
        })
    
    async def _send_progress_notification(self, params: dict):
        """Send progress notification (implement based on your context)"""
        pass

@asynccontextmanager
async def progress_context(
    token: str, 
    total: float | None = None
) -> AsyncContextManager[ProgressReporter]:
    """Context manager for automatic progress completion"""
    reporter = ProgressReporter(token, total)
    try:
        yield reporter
    finally:
        # Ensure completion is reported
        await reporter.report(reporter.total or 1.0, "Complete")

@mcp.tool()
async def long_running_task_with_progress(
    data: list[str], 
    progress_token: str | None = None
) -> dict:
    """Tool demonstrating proper progress reporting"""
    total_items = len(data)
    results = []
    
    if progress_token:
        async with progress_context(progress_token, total_items) as progress:
            for i, item in enumerate(data):
                # Process item
                result = await process_item(item)
                results.append(result)
                
                # Report progress
                await progress.report(
                    i + 1, 
                    f"Processed {i + 1}/{total_items} items"
                )
    else:
        # Process without progress reporting
        for item in data:
            result = await process_item(item)
            results.append(result)
    
    return {
        "success": True, 
        "results": results, 
        "total_processed": len(results)
    }
```

## Type Safety Checklist

### Essential Practices

- [ ] **ConfigDict**: All models use `ConfigDict(extra="allow")`
- [ ] **Type Hints**: All functions have complete type annotations
- [ ] **Union Types**: Use specific unions instead of `Any`
- [ ] **Validation**: Implement field validators for business rules
- [ ] **Error Handling**: Use typed error responses
- [ ] **Generics**: Leverage generic types for reusable components

### Advanced Practices

- [ ] **Annotated Types**: Use `Annotated` for enhanced validation
- [ ] **Pattern Matching**: Use match/case for union type handling
- [ ] **Progress Reporting**: Implement typed progress notifications
- [ ] **Custom Validators**: Create reusable validation factories
- [ ] **Resource Typing**: Type resources with proper validation
- [ ] **Tool Typing**: Ensure tool inputs/outputs are fully typed

### Performance Considerations

- [ ] **Lazy Validation**: Use Pydantic's lazy validation for large datasets
- [ ] **Model Caching**: Cache model validation for repeated operations
- [ ] **Streaming**: Use async generators for large result sets
- [ ] **Memory Management**: Consider memory usage for large content types

## Example: Complete Type-Safe Tool

Here's a comprehensive example showcasing all best practices:

```python
from typing import Annotated, Optional, Union
from pydantic import BaseModel, ConfigDict, Field, validator
from enum import Enum

class ProcessingMode(str, Enum):
    """Enumeration for processing modes"""
    FAST = "fast"
    THOROUGH = "thorough"
    BALANCED = "balanced"

class ProcessingParams(BaseModel):
    """Fully typed parameters for document processing"""
    file_path: Annotated[str, Field(min_length=1, description="Path to file")]
    mode: ProcessingMode = ProcessingMode.BALANCED
    priority: Annotated[float, Field(ge=0.0, le=1.0)] = 0.5
    max_results: Annotated[int, Field(gt=0, le=1000)] = 100
    include_metadata: bool = True
    tags: list[str] = Field(default_factory=list, max_items=10)
    
    @validator('file_path')
    def validate_file_path(cls, v):
        """Ensure file path is valid"""
        if not v.strip():
            raise ValueError("File path cannot be empty")
        return v.strip()
    
    model_config = ConfigDict(extra="allow")

class ProcessingResult(BaseModel):
    """Typed result for document processing"""
    success: bool
    content: list[ContentType]
    metadata: dict[str, Any] = Field(default_factory=dict)
    processing_time: float
    items_processed: int
    
    model_config = ConfigDict(extra="allow")

@mcp.tool()
async def process_document_typed(
    params: ProcessingParams,
    progress_token: Optional[str] = None
) -> ProcessingResult:
    """Fully type-safe document processing tool"""
    start_time = time.time()
    
    try:
        # Validate file exists
        if not os.path.exists(params.file_path):
            raise FileNotFoundError(f"File not found: {params.file_path}")
        
        # Process with progress reporting
        content_list = []
        items_processed = 0
        
        if progress_token:
            async with progress_context(progress_token, 100.0) as progress:
                # Simulate processing steps
                for i in range(params.max_results):
                    # Process item
                    item_content = await process_item(
                        params.file_path, 
                        i, 
                        params.mode
                    )
                    content_list.append(item_content)
                    items_processed += 1
                    
                    # Report progress
                    progress_pct = (i + 1) / params.max_results * 100
                    await progress.report(
                        progress_pct,
                        f"Processed {i + 1}/{params.max_results} items"
                    )
        else:
            # Process without progress
            for i in range(params.max_results):
                item_content = await process_item(
                    params.file_path, 
                    i, 
                    params.mode
                )
                content_list.append(item_content)
                items_processed += 1
        
        # Build result
        processing_time = time.time() - start_time
        metadata = {
            "mode": params.mode,
            "priority": params.priority,
            "tags": params.tags
        } if params.include_metadata else {}
        
        return ProcessingResult(
            success=True,
            content=content_list,
            metadata=metadata,
            processing_time=processing_time,
            items_processed=items_processed
        )
        
    except Exception as e:
        # Return typed error result
        return ProcessingResult(
            success=False,
            content=[create_text_content(f"Error: {str(e)}")],
            metadata={"error": str(e), "error_type": type(e).__name__},
            processing_time=time.time() - start_time,
            items_processed=0
        )
```

## Conclusion

Following these typing best practices ensures your MCP server is:

- **Type-safe**: Comprehensive type checking prevents runtime errors
- **Maintainable**: Clear type annotations improve code readability
- **Protocol-compliant**: Proper MCP type usage ensures compatibility
- **Extensible**: `extra="allow"` supports future protocol extensions
- **Robust**: Comprehensive validation catches edge cases early
- **Performance-optimized**: Proper typing enables better optimization

By leveraging Pydantic's validation capabilities and Python's advanced typing features, you can build MCP servers that are both powerful and reliable.