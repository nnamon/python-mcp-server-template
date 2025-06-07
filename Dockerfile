# Use Python 3.12 slim image for smaller size
FROM python:3.12-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install uv for fast package management
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

# Create non-root user for security
RUN useradd --create-home --shell /bin/bash mcp

# Set working directory
WORKDIR /app

# Copy dependency files
COPY pyproject.toml uv.lock ./

# Install dependencies
RUN uv sync --frozen --no-dev

# Copy application code
COPY . .

# Change ownership to non-root user
RUN chown -R mcp:mcp /app

# Switch to non-root user
USER mcp

# Expose port (if your MCP server uses HTTP instead of stdio)
# EXPOSE 8000

# Set the default command
# For stdio-based MCP servers (most common):
CMD ["uv", "run", "mcp"]

# For HTTP-based MCP servers, uncomment and modify as needed:
# CMD ["uv", "run", "python", "-m", "src.mcp_server_template.server"]