# Initialize New MCP Server Project

This command helps you quickly initialize a new MCP server project from this template by replacing all placeholders with your project-specific values.

## CRITICAL WORKFLOW FOR CLAUDE CODE:

**When the user asks to initialize a new project, you MUST:**

1. **FIRST: Gather the user's requirements**
   - What will the MCP server do?
   - What should the package be named?
   - What's the server name for MCP clients?
   - What's the Docker image name?
   - What's the repository URL?

2. **THEN: Edit the initialize.sh script with the gathered values**
   ```bash
   # Edit the export variables at the top of initialize.sh:
   export SERVER_DESCRIPTION="[user's description]"
   export PACKAGE_NAME="[user's package name]"
   export SERVER_NAME="[user's server name]"
   export DOCKER_IMAGE_NAME="[user's docker image name]"
   export PROJECT_NAME="[project name or leave empty for current dir]"
   export REPOSITORY_URL="[user's repo URL]"
   ```

3. **FINALLY: Run the script**
   ```bash
   ./initialize.sh
   ```

The script will handle everything automatically - no manual steps needed!

## What this command will do (after initialize.sh):

1. **Verify the initialization was complete** - check that all placeholders were properly replaced
2. **Confirm template files were cleaned up** - ensure initialize.sh and .claude/commands were removed
3. **Review the generated code** for any missed customizations
4. **Help customize the actual MCP tools** - replace example tools with your specific functionality
5. **Update data models** to match your use case
6. **Add any additional configuration** needed for your specific server
7. **Verify the project builds and tests pass** after customization

## If you haven't run initialize.sh yet:

If you prefer to do everything manually or the script didn't work, I can help gather requirements:

1. **What will your MCP server do?** 
   - Examples: "manage databases", "process documents", "integrate with APIs", "analyze code"
   - This helps me understand the purpose and suggest appropriate naming

2. **What would you like to name your project?**
   - This will be used for the project directory name and Docker images
   - Examples: "database-manager", "document-processor", "api-integrator"

3. **What should the Python package be called?**
   - Must be a valid Python identifier (lowercase, underscores only)
   - Examples: "database_manager", "document_processor", "api_integrator"

4. **What's a brief description of your server?**
   - This will go in pyproject.toml and documentation
   - Examples: "MCP server for database management", "Document processing MCP server"

## Customization Process:

After gathering your requirements, I will:

1. **Find all placeholders** using:
   ```bash
   grep -r "PLACEHOLDER_" . --exclude-dir=.git
   grep -r "placeholder-" . --exclude-dir=.git  
   grep -r "placeholder_" . --exclude-dir=.git
   ```

2. **Replace these placeholders in ALL files:**
   - `PLACEHOLDER_PROJECT_NAME` → your project directory name
   - `PLACEHOLDER_SERVER_NAME` → your server name for MCP client config
   - `PLACEHOLDER_PACKAGE_NAME` → your Python package name (in pyproject.toml only)
   - `PLACEHOLDER_SERVER_DESCRIPTION` → your server description
   - `placeholder-mcp-server` → your Docker image name
   - `placeholder_package_name` → your package directory name

3. **Files that will be updated:**
   - `pyproject.toml` - name and description
   - `main.py` - description and docstring
   - `src/mcp_server_template/server.py` - FastMCP server name and description
   - `src/mcp_server_template/__init__.py` - package description
   - `tests/test_server.py` - test descriptions
   - `tests/__init__.py` - test package description
   - `Makefile` - help text and comments
   - `README.md` - all placeholder references
   - `docker-compose.yml` - service names
   - `CLAUDE.md` - all placeholder references

4. **Rename package directory:**
   ```bash
   mv src/mcp_server_template src/your_package_name
   ```

5. **Update all imports** in:
   - `main.py` - import statement
   - `tests/test_server.py` - import statement
   - `pyproject.toml` - packages list
   - `docker-compose.yml` - commented command examples

6. **Run tests** to ensure everything works:
   ```bash
   make test
   make lint
   ```

7. **Clean up template-specific files:**
   ```bash
   # Remove the initialization script
   rm initialize.sh
   
   # Remove template slash commands
   rm -rf .claude/commands/
   ```

8. **Rewrite CLAUDE.md** to be project-specific and remove template instructions

## Ready to start?

**REMEMBER: The correct workflow is:**
1. Gather requirements from the user
2. Edit the export variables in initialize.sh
3. Run ./initialize.sh

**The script will automatically:**
- Replace ALL placeholders
- Rename the package directory  
- Update all imports
- Run tests to verify setup
- Rewrite CLAUDE.md
- Clean up template files
- Show a summary of the configuration

**DO NOT attempt manual placeholder replacement** - the script handles everything!

If the user has already run initialize.sh, verify the initialization was complete and help with any remaining customization of the actual MCP tools and functionality.