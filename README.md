# C-AST-generator

Abstract Syntax Tree (AST) generator for the C language using **Flex**, **Bison**, and the C++ API.

## Status
**Project in Progress** — many C constructs (like `if`, `else`, `for`, `while`, etc.) are **not yet implemented**.  
Currently supported:
- Variable declarations
- Function declarations

## Usage
1. Write your C code in a test file (e.g., `test`).
2. Run:
   ```bash
   ./run.sh
3. Outputs:
- `ast.json` — JSON representation of the AST  
- `ast.pdf` — visual representation of the AST

