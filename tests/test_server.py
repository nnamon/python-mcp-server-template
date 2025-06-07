"""
Test suite for MCP Server Template.

Simple tests for the basic MCP server functionality.
"""


# Import the tools directly from the server module
from src.mcp_server_template.server import (
    add_numbers,
    echo_message,
    explain_concept,
    get_config,
    get_greeting,
    review_code,
)


class TestTools:
    """Test MCP tools"""

    def test_add_numbers(self):
        """Test the add_numbers tool"""
        result = add_numbers(2, 3)
        assert result == 5

    def test_echo_message(self):
        """Test the echo_message tool"""
        result = echo_message("Hello")
        assert result == "You said: Hello"


class TestResources:
    """Test MCP resources"""

    def test_get_config(self):
        """Test the config resource"""
        result = get_config()
        assert "configuration" in result

    def test_get_greeting(self):
        """Test the greeting resource with parameter"""
        result = get_greeting("Alice")
        assert "Hello, Alice!" in result


class TestPrompts:
    """Test MCP prompts"""

    def test_review_code(self):
        """Test the code review prompt"""
        code = "def hello(): print('world')"
        result = review_code(code)
        assert "review this code" in result
        assert code in result

    def test_explain_concept(self):
        """Test the concept explanation prompt"""
        result = explain_concept("recursion")
        assert "recursion" in result
        assert "explain" in result
