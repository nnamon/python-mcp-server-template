# PLACEHOLDER_SERVER_DESCRIPTION Makefile

.PHONY: help install test format lint run dev clean

# Default target
help:
	@echo "PLACEHOLDER_SERVER_DESCRIPTION Commands"
	@echo "============================"
	@echo ""
	@echo "  install    Install dependencies"
	@echo "  test       Run tests"
	@echo "  format     Format code"
	@echo "  lint       Run linting"
	@echo "  run        Run MCP server"
	@echo "  dev        Run MCP server with inspector"
	@echo "  clean      Clean cache files"

install:
	uv sync

test:
	uv run pytest

format:
	uv run ruff format .

lint:
	uv run ruff check .

run:
	uv run mcp run main.py

dev:
	uv run mcp dev main.py

clean:
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null || true