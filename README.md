# baremetal-c

A minimal C project template for Linux.

## 1. Introduction and Goals

`baremetal-c` is a starter template for Linux C projects: a directory layout, Makefile, and out-of-source build setup, with editor tooling wired in as a convenience.

**Primary Goals:**
*   **Artifact Isolation:** Strictly separate build artifacts from source files.
*   **Editor Agnosticism:** Provide seamless integration with lightweight editors (Vim, Emacs) via standard tooling (`clangd`, `ctags`, `bear`).
*   **Minimalist Toolchain:** Avoid heavy abstraction layers by relying on POSIX standards and standard compiler flags.

## 2. Architecture Constraints
*   **Target OS:** Linux.
*   **Language Standard:** ISO C11.
*   **Compiler:** `clang` (default) or `gcc`.
*   **Build System:** POSIX `make`.
*   **Debugger:** `gdb`.
*   **Tooling:** `bear` (compilation database), `ctags` (source indexing), `clangd` (LSP).

## 3. System Scope and Context
* **Business Context:** The system serves as a local development template for starting new bare-metal or systems-level Linux C applications.
* **Technical Context:** The template provides the scaffold to take `.c` source files and `.h` headers, process them through a POSIX `make` pipeline, and produce native Linux ELF binary executables while simultaneously generating metadata (`compile_commands.json`, `tags`) for editor integration.

## 4. Solution Strategy
*   **Out-of-source compilation:** All object files (`.o`), dependency files (`.d`), and executables are routed to a transient `build/` directory to prevent source tree pollution.  
*   **Header Dependency Tracking:** Compiler flags (`-MMD -MP`) automatically generate dependency rules during compilation, ensuring precise recompilation when headers are modified.  
*   **Automated Tooling Sync:** A dedicated `bootstrap.sh` script automates the generation of AST databases and editor tags to keep LSP and navigation features perfectly synced with the current build state.

## 5. Building Block View
### Level 1: Directory Structure
*   `.clang-format`: Code style rules enforced statically across the source tree.
*   `.editorconfig`: Baseline editor settings (indentation, line endings, charset) for editors without `clang-format` integration.
*   `.gitignore`: Excludes `build/` and generated tooling artifacts from version control.
*   `bootstrap.sh`: Developer utility script for environment reset and toolchain generation.
*   `build/`: Transient directory for generated artifacts (ignored by VCS).
    *   `build/obj/`: Intermediate object blocks and dependency tracking files.
    *   `build/bin/`: Final linked executables.
*   `src/`: Contains all `.c` source implementations (e.g., `main.c`).
*   `include/`: Contains all `.h` public header definitions (e.g., `main.h`).
*   `Makefile`: Build logic, dependency generation, and target definitions.

## 6. Runtime View
### 6.1 Standard Build Sequence
1.  `make` invoked.
2.  Compiler compiles modified `.c` files in `src/` to `.o` files in `build/obj/`.
3.  Compiler writes dependency `.d` files to `build/obj/`.
4.  Linker aggregates `.o` files into the final executable in `build/bin/app`.

### 6.2 Environment Bootstrap Sequence (`bootstrap.sh`)
1.  Cleans environment (`make clean`).
2.  Purges stale editor caches (`.cache`, `.clangd`, `tags`, `compile_commands.json`).
3.  Executes `bear -- make debug` to perform a fresh debug build and capture AST parsing commands.
4.  Executes `ctags -R .` to index the source tree.
5.  Outputs the generated build targets.

## 8. Cross-cutting Concepts
*   **Editor Integration:** `bear` and `ctags` are used instead of an IDE plugin because they work with any editor, not just ones with built-in language tooling. Vim/Neovim and Emacs get symbol navigation and `clangd` support as a result.
*   **Code Style Enforcement:** `.clang-format` is applied because manual formatting drifts across contributors. `.editorconfig` is included because not every editor runs `clang-format` directly.
*   **Memory & Debugging:** `make debug` sets `-g -O0 -DDEBUG` because `gdb` needs unoptimized code and full DWARF symbols to give accurate line-level debugging.

## 9. Architecture Decisions
*   **ADR-01: Artifact Segregation:** Source directories shall contain zero generated files. *Rationale:* Simplifies version control, prevents accidental commits of binaries, and keeps editor file-trees clean.
*   **ADR-02: POSIX Make over CMake:** Direct POSIX Makefiles are used instead of CMake or Meson. *Rationale:* Reduces abstraction layers, limits dependencies for minimal Linux environments, and offers total transparency of compiler flags.
*   **ADR-03: Bear for LSP Database:** `bear` is used to generate `compile_commands.json` rather than relying on CMake's built-in generator. *Rationale:* Preserves the ability to use POSIX Make while still providing first-class language server support.

## 12. Glossary
*   **LSP:** Language Server Protocol. A protocol used between editors and language smartness providers (like `clangd`).
*   **AST:** Abstract Syntax Tree.
*   **Bear:** A tool that generates a compilation database (`compile_commands.json`) for clang tooling by intercepting compiler calls during the build process.
*   **Ctags:** A programming tool that generates an index (or tag file) of names found in source and header files for fast editor navigation.

---

## References
*   [arc42](https://arc42.org) — architecture communication template followed by this document.
*   [Bear](https://github.com/rizsotto/Bear) — compilation database tool referenced in §2, §4, §6.2, §8, §9, §12.
*   [EditorConfig](https://editorconfig.org) — editor settings spec referenced in §5, §8.
*   [GNU Debugger (GDB)](https://www.gnu.org/software/gdb/) — debugger referenced in §2, §8.
*   [ISO/IEC 9899:2011 (C11)](https://www.iso.org/standard/57853.html) — language standard referenced in §2.
*   [Universal Ctags](https://ctags.io) — source indexing tool referenced in §2, §6.2, §8, §12.
*   [clang-format](https://clang.llvm.org/docs/ClangFormat.html) — code style tool referenced in §5, §8.
*   [clangd](https://clangd.llvm.org) — language server referenced in §1, §2, §8.
