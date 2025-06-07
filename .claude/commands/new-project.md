# Initialize New MCP Server Project

This command helps you quickly initialize a new MCP server project from this template by replacing all placeholders with your project-specific values.

## What this command will do:

1. **Detect if this is a spawned project** (directory name != `python-mcp-server-template`)
2. **Gather your project requirements** through interactive questions
3. **Replace all placeholders** throughout the codebase with your values
4. **Rename the package directory** from `mcp_server_template` to your package name
5. **Update all import statements** to use your new package name
6. **Verify the project builds** after customization

## Project Requirements:

I need to gather some information about your MCP server project:

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

2. **Replace these placeholders:**
   - `PLACEHOLDER_PROJECT_NAME` → your project directory name
   - `PLACEHOLDER_SERVER_NAME` → your server name for MCP client config
   - `PLACEHOLDER_PACKAGE_NAME` → your Python package name
   - `PLACEHOLDER_SERVER_DESCRIPTION` → your server description
   - `placeholder-mcp-server` → your Docker image name
   - `placeholder_package_name` → your package directory name

3. **Rename package directory:**
   ```bash
   mv src/mcp_server_template src/your_package_name
   ```

4. **Update all imports** in:
   - `main.py`
   - `tests/test_server.py`
   - Any other files referencing the old package

5. **Update project metadata** in `pyproject.toml`

6. **Run tests** to ensure everything works:
   ```bash
   make test
   make lint
   ```

7. **Rewrite CLAUDE.md** to be project-specific and remove template instructions

## Ready to start?

Please provide your answers to the questions above, and I'll transform this template into your custom MCP server project!