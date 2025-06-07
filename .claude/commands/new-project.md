# Initialize New MCP Server Project

This command helps you quickly initialize a new MCP server project from this template by replacing all placeholders with your project-specific values.

## Recommended Approach: Use the Bash Script First

**STEP 1: Run the automated initialization script**

```bash
./initialize.sh
```

This script will handle most of the initialization automatically:
- Interactive guided setup with input validation
- Replace all placeholders systematically
- Rename packages and update imports
- Run tests to verify everything works
- Generate project-specific documentation

**STEP 2: Manual verification and Claude assistance**

After running the script, use this slash command to have Claude verify and complete any remaining customization:

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

**If you've already run `./initialize.sh`:**
- The script should have already cleaned up template files automatically
- Just let me know and I'll verify the initialization was complete and help with any remaining customization

**If you haven't run the script yet:**
- Please run `./initialize.sh` first for the best experience, then come back to this command
- OR provide your answers to the questions above, and I'll do the manual transformation

Either way, I'll help ensure your MCP server template becomes a fully customized project!