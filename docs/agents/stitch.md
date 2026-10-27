# Stitch MCP Reference & Conventions

This project integrates with Google Stitch design systems via the `StitchMCP` server.

## Resource Identifier Formats

Stitch tools require fully qualified resource path names rather than separate query parameters.

### 1. `get_screen`
- **Argument**: `name: "projects/<projectId>/screens/<screenId>"`
- **Example**:
  ```json
  {
    "name": "projects/17379303513097715140/screens/c87623d463a14b99b8fa338763bedff9"
  }
  ```

### 2. `download_file`
- **Argument**: `name: "projects/<projectId>/files/<fileId>"`
- **Returns**: A JSON payload wrapping the HTML/file content: `{"html": "<!DOCTYPE html>..."}`

### 3. `list_screens`
- **Argument**: `projectId: "projects/<projectId>"`
- **Example**:
  ```json
  {
    "projectId": "projects/17379303513097715140"
  }
  ```

## Active Project

- **Productive Muslim Stitch Project ID**: `projects/17379303513097715140`
