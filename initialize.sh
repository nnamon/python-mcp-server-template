#!/bin/bash

# MCP Server Template Initialization Script
# This script automatically customizes the template for your specific use case

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to validate input
validate_package_name() {
    local name="$1"
    if [[ ! "$name" =~ ^[a-z][a-z0-9_]*$ ]]; then
        return 1
    fi
    return 0
}

validate_docker_name() {
    local name="$1"
    if [[ ! "$name" =~ ^[a-z][a-z0-9-]*$ ]]; then
        return 1
    fi
    return 0
}

# Function to check if this is the template repository
check_if_template() {
    local current_dir=$(basename "$PWD")
    if [[ "$current_dir" == "python-mcp-server-template" ]]; then
        print_warning "This appears to be the original template repository."
        print_warning "Are you sure you want to customize it? (y/N)"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            print_error "Initialization cancelled. Please use this script in a spawned project."
            exit 1
        fi
    fi
}

# Function to gather user input
gather_requirements() {
    print_status "Setting up your MCP server project..."
    echo
    
    # Server description
    echo "What will your MCP server do?"
    echo "Examples: 'Database management server', 'Document processing server', 'API integration server'"
    read -p "Description: " server_description
    
    while [[ -z "$server_description" ]]; do
        print_error "Description cannot be empty."
        read -p "Description: " server_description
    done
    
    # Package name
    echo
    echo "What should the Python package be called?"
    echo "Must be lowercase with underscores only (e.g., 'database_manager', 'document_processor')"
    read -p "Package name: " package_name
    
    while ! validate_package_name "$package_name"; do
        print_error "Invalid package name. Must be lowercase letters, numbers, and underscores only, starting with a letter."
        read -p "Package name: " package_name
    done
    
    # Server name for MCP clients
    echo
    echo "What should the server be called in MCP client configurations?"
    echo "This will be used as the server identifier (e.g., 'database-manager', 'document-processor')"
    read -p "Server name: " server_name
    
    while [[ -z "$server_name" ]]; do
        print_error "Server name cannot be empty."
        read -p "Server name: " server_name
    done
    
    # Docker image name
    echo
    echo "What should the Docker image be called?"
    echo "Must be lowercase with hyphens (e.g., 'my-database-server', 'doc-processor')"
    read -p "Docker image name: " docker_name
    
    while ! validate_docker_name "$docker_name"; do
        print_error "Invalid Docker name. Must be lowercase letters, numbers, and hyphens only, starting with a letter."
        read -p "Docker image name: " docker_name
    done
    
    # Project directory name (derived from current directory or ask)
    project_name=$(basename "$PWD")
    echo
    echo "Current directory name '$project_name' will be used as the project name."
    echo "Press Enter to accept, or type a new name:"
    read -p "Project name [$project_name]: " input_project_name
    
    if [[ -n "$input_project_name" ]]; then
        project_name="$input_project_name"
    fi
    
    # Repository URL for clone instructions
    echo
    echo "What is the URL of this repository?"
    echo "This will be used in README.md clone instructions (e.g., 'https://github.com/user/repo.git')"
    read -p "Repository URL: " repo_url
    
    while [[ -z "$repo_url" ]]; do
        print_error "Repository URL cannot be empty."
        read -p "Repository URL: " repo_url
    done
}

# Function to replace placeholders in files
replace_placeholders() {
    print_status "Replacing placeholders in all files..."
    
    # Files to update (excluding the package directory which we'll rename)
    local files=(
        "pyproject.toml"
        "main.py"
        "src/mcp_server_template/server.py"
        "src/mcp_server_template/__init__.py"
        "tests/test_server.py"
        "tests/__init__.py"
        "Makefile"
        "README.md"
        "docker-compose.yml"
        "CLAUDE.md"
    )
    
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            print_status "Updating $file..."
            
            # Use different sed syntax for macOS vs Linux
            if [[ "$OSTYPE" == "darwin"* ]]; then
                # macOS
                sed -i '' "s/PLACEHOLDER_SERVER_DESCRIPTION/$server_description/g" "$file"
                sed -i '' "s/PLACEHOLDER_SERVER_NAME/$server_name/g" "$file"
                sed -i '' "s/PLACEHOLDER_PACKAGE_NAME/$package_name/g" "$file"
                sed -i '' "s/PLACEHOLDER_PROJECT_NAME/$project_name/g" "$file"
                sed -i '' "s|PLACEHOLDER_REPO_URL|$repo_url|g" "$file"
                sed -i '' "s/placeholder-mcp-server/$docker_name/g" "$file"
                sed -i '' "s/placeholder_package_name/$package_name/g" "$file"
            else
                # Linux
                sed -i "s/PLACEHOLDER_SERVER_DESCRIPTION/$server_description/g" "$file"
                sed -i "s/PLACEHOLDER_SERVER_NAME/$server_name/g" "$file"
                sed -i "s/PLACEHOLDER_PACKAGE_NAME/$package_name/g" "$file"
                sed -i "s/PLACEHOLDER_PROJECT_NAME/$project_name/g" "$file"
                sed -i "s|PLACEHOLDER_REPO_URL|$repo_url|g" "$file"
                sed -i "s/placeholder-mcp-server/$docker_name/g" "$file"
                sed -i "s/placeholder_package_name/$package_name/g" "$file"
            fi
        else
            print_warning "File $file not found, skipping..."
        fi
    done
}

# Function to rename package directory and update imports
rename_package() {
    print_status "Renaming package directory from 'mcp_server_template' to '$package_name'..."
    
    # Rename the package directory
    if [[ -d "src/mcp_server_template" ]]; then
        mv "src/mcp_server_template" "src/$package_name"
        print_success "Package directory renamed successfully."
    else
        print_error "Package directory 'src/mcp_server_template' not found!"
        exit 1
    fi
    
    # Update imports in files
    local import_files=(
        "main.py"
        "tests/test_server.py"
        "pyproject.toml"
    )
    
    print_status "Updating import statements..."
    for file in "${import_files[@]}"; do
        if [[ -f "$file" ]]; then
            print_status "Updating imports in $file..."
            
            if [[ "$OSTYPE" == "darwin"* ]]; then
                # macOS
                sed -i '' "s/mcp_server_template/$package_name/g" "$file"
            else
                # Linux
                sed -i "s/mcp_server_template/$package_name/g" "$file"
            fi
        fi
    done
    
    # Update commented examples in docker-compose.yml
    if [[ -f "docker-compose.yml" ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/src\\.mcp_server_template/src.$package_name/g" "docker-compose.yml"
        else
            sed -i "s/src\\.mcp_server_template/src.$package_name/g" "docker-compose.yml"
        fi
    fi
}

# Function to run tests
run_tests() {
    print_status "Running tests to verify everything works..."
    
    # Check if make is available
    if command -v make >/dev/null 2>&1; then
        if make test >/dev/null 2>&1; then
            print_success "All tests passed!"
        else
            print_error "Tests failed. Please check the output above."
            return 1
        fi
        
        if make lint >/dev/null 2>&1; then
            print_success "Linting passed!"
        else
            print_error "Linting failed. Please check the output above."
            return 1
        fi
    else
        print_warning "Make not found, skipping automated tests."
        print_warning "Please run 'make test' and 'make lint' manually to verify the setup."
    fi
}

# Function to update CLAUDE.md to project-specific version
update_claude_md() {
    print_status "Updating CLAUDE.md to be project-specific..."
    
    cat > CLAUDE.md << EOF
# $server_description - Claude Code Instructions

## Project Overview

This is a **$server_description** built using the FastMCP framework from the MCP Python SDK.

### Key Technologies & Dependencies
- **FastMCP**: Framework from the MCP Python SDK for rapid server development
- **uv**: Fast Python package and project manager
- **ruff**: Code formatting and linting
- **pytest**: Testing framework with async support
- **Docker**: Containerization support included
- **Pydantic**: Type safety and data validation

### Project Structure
\`\`\`
├── main.py                    # Server entry point
├── src/$package_name/         # Main package
│   ├── server.py             # MCP server implementation
│   └── models.py             # Pydantic models
├── tests/                    # Test suite
├── Makefile                  # Development commands
└── pyproject.toml           # Project configuration
\`\`\`

## Development Workflow

**CRITICAL: Always use feature branches and pull requests. NEVER commit directly to main.**

### Required Workflow
1. **Create feature branch**: \`git checkout -b [type]/description-of-work\`
2. **Implement changes** only on the feature branch
3. **Test functionality**: \`make test\` and \`make lint\`
4. **Commit changes** to feature branch with descriptive messages
5. **Push branch**: \`git push -u origin [branch-name]\`
6. **Test with running application**: Before creating a PR, ask the user to verify the changes work with \`make dev\`
7. **Create Pull Request**: Use \`gh pr create\` with proper title and description ONLY after all tests pass

### Branch Naming Convention
- \`feature/\` - New features or MCP primitives
- \`fix/\` - Bug fixes
- \`refactor/\` - Code refactoring
- \`docs/\` - Documentation updates

## Make Commands

\`\`\`bash
make install    # Install dependencies with uv
make test      # Run pytest test suite
make format    # Format code with ruff
make lint      # Run ruff linting
make run       # Run MCP server in production mode
make dev       # Run MCP server with inspector for development
make clean     # Clean cache files
\`\`\`

## Common Tasks Claude Should Help With

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

\`\`\`bash
docker-compose up --build    # Start development environment
docker-compose exec app bash # Access container shell
\`\`\`
EOF

    print_success "CLAUDE.md updated to be project-specific."
}

# Function to clean up template files
cleanup_template_files() {
    print_status "Cleaning up template-specific files..."
    
    # Remove the initialization script itself
    if [[ -f "initialize.sh" ]]; then
        rm "initialize.sh"
        print_success "Removed initialization script."
    fi
    
    # Remove the slash command since it's template-specific
    if [[ -d ".claude/commands" ]]; then
        rm -rf ".claude/commands"
        print_success "Removed template slash commands."
    fi
}

# Function to show summary
show_summary() {
    echo
    print_success "🎉 Template initialization completed successfully!"
    echo
    echo "Your MCP server project is now configured with:"
    echo "  📝 Description: $server_description"
    echo "  📦 Package name: $package_name"
    echo "  🏷️  Server name: $server_name"  
    echo "  🐳 Docker image: $docker_name"
    echo "  📁 Project name: $project_name"
    echo "  🔗 Repository URL: $repo_url"
    echo
    echo "Next steps:"
    echo "  1. Review and customize the tools in src/$package_name/server.py"
    echo "  2. Update the data models in src/$package_name/models.py"
    echo "  3. Add tests for your specific functionality"
    echo "  4. Run 'make dev' to test your server with the MCP inspector"
    echo "  5. Build and test with Docker: 'docker build -t $docker_name .'"
    echo
    print_success "Happy coding! 🚀"
}

# Main execution
main() {
    echo "=============================================="
    echo "  MCP Server Template Initialization Script"
    echo "=============================================="
    echo
    
    # Check if this is the template repository
    check_if_template
    
    # Gather user requirements
    gather_requirements
    
    echo
    print_status "Configuration summary:"
    echo "  Description: $server_description"
    echo "  Package name: $package_name"
    echo "  Server name: $server_name"
    echo "  Docker image: $docker_name"
    echo "  Project name: $project_name"
    echo "  Repository URL: $repo_url"
    echo
    
    read -p "Proceed with initialization? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_error "Initialization cancelled."
        exit 1
    fi
    
    # Perform the initialization
    replace_placeholders
    rename_package
    run_tests
    update_claude_md
    cleanup_template_files
    show_summary
}

# Run main function
main "$@"