# baremetal-c

[![CI](https://github.com/rbento/baremetal-c/actions/workflows/makefile.yml/badge.svg?branch=main)](https://github.com/rbento/baremetal-c/actions/workflows/makefile.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A minimal starter template for bare-metal C programming, custom game engines, graphics pipelines, and deliberate practice.

## Introduction and Goals

`baremetal-c` is a minimal template for deliberate practice while programming bare-metal C without frameworks or runtime dependencies.

**Primary Goals:**
*   **Artifact Isolation:** Strictly separate build outputs from the source tree.
*   **Zero-Framework Minimalism:** Provide an unopinionated C environment free from heavy meta-build abstractions.
*   **Editor Agnosticism:** Integrate seamlessly with lightweight editors (Vim, Emacs) via standard CLI tooling (`clangd`, `ctags`, `bear`).

```bash
git clone https://github.com/rbento/baremetal-c.git my-project
cd my-project
./bootstrap.sh
make run
```

## Architecture Constraints
*   **Target OS:** Linux.
*   **Language Standard:** ISO C11.
*   **Compiler:** `clang` (default) or `gcc`.
*   **Build System:** POSIX `make`.
*   **Debugger:** `gdb`.
*   **Tooling:** `bear` (compilation database), `ctags` (source indexing), `clangd` (LSP).

## System Scope and Context
*   **Context:** The template serves as a generic starting point for bare-metal C projects—ranging from custom game engines and hardware renderers to systems utilities and deliberate programming katas.
*   **Technical Scope:** The pipeline consumes raw `.c` source files and `.h` headers, processes them through a direct POSIX `make` workflow, produces native ELF executables in `build/bin/`, and exports editor metadata (`compile_commands.json`, `tags`).

## Solution Strategy
*   **Out-of-Source Compilation:** Object files (`.o`), dependency files (`.d`), and executables route exclusively to a transient `build/` tree to keep the repository root clean.
*   **Header Dependency Tracking:** Compiler flags (`-MMD -MP`) generate Make prerequisites during compilation, ensuring proper recompilation when included headers change.
*   **Automated Tooling Sync:** `bootstrap.sh` automates the generation of `compile_commands.json` and tag indexes so editor LSP diagnostics and navigation match the current build state.

## Building Block View
### Level 1: Directory Structure
*   `.clang-format`: Formatting rules applied across the repository.
*   `.editorconfig`: Fallback editor indentation, charset, and line-ending rules.
*   `.gitignore`: Excludes `build/` and generated tooling artifacts from version control.
*   `bootstrap.sh`: Shell script for clean rebuilding and tooling generation.
*   `build/`: Transient output tree (ignored by Git).
    *   `build/obj/`: Compiled object files (`.o`) and dependency graphs (`.d`).
    *   `build/bin/`: Final linked executables.
*   `src/`: Implementation files (`.c`).
*   `include/`: Public headers (`.h`).
*   `Makefile`: Build rules, dependency includes, and compiler targets.

## Runtime View
### Standard Build Sequence
1.  `make` is executed.
2.  The compiler compiles modified `.c` files in `src/` into `.o` objects in `build/obj/`.
3.  The compiler writes header dependency `.d` files alongside object files in `build/obj/`.
4.  The linker combines all `.o` objects into the final binary inside `build/bin/`.

### Environment Bootstrap Sequence (`bootstrap.sh`)
1.  Invokes `make clean` to purge existing build artifacts.
2.  Removes stale caches and editor indexes (`.cache`, `.clangd`, `tags`, `compile_commands.json`).
3.  Executes `bear -- make debug` to run a debug build (`-g -O0 -DDEBUG`) while capturing compiler invocations into `compile_commands.json`.
4.  Runs `ctags -R .` to index function signatures and identifiers for tag-based navigation.
5.  Prints the output paths of all generated artifacts.

## Cross-cutting Concepts
*   **Editor Integration:** Standard CLI tools (`bear`, `ctags`) are preferred over IDE-specific extensions. Any editor implementing LSP (`clangd`) or tags gets jump-to-definition, code completion, and diagnostics out of the box.
*   **Code Style Enforcement:** `.clang-format` handles syntax layout deterministically to prevent diff noise. `.editorconfig` provides basic whitespace settings for environments without an active LSP.
*   **Debugging Instrumentation:** The `make debug` target applies `-g -O0 -DDEBUG` so `gdb` retains full DWARF symbol tables and avoids instruction reordering during stepping.

## Architecture Decisions
*   **ADR-01: Artifact Segregation:** Source directories must contain zero generated files. *Rationale:* Prevents clutter, simplifies `.gitignore`, and eliminates accidental binary check-ins.
*   **ADR-02: POSIX Make over CMake:** Direct Makefiles are chosen over CMake or Meson. *Rationale:* Eliminates meta-build dependencies, keeps the build process transparent, and avoids unnecessary abstractions for C projects.
*   **ADR-03: Bear for LSP Support:** `bear` is used to intercept `make` rather than migrating the project to CMake solely for `CMAKE_EXPORT_COMPILE_COMMANDS`. *Rationale:* Retains the simplicity of a raw Makefile while maintaining full `clangd` language server support.

## Glossary
*   **Bear:** A build-interception tool that generates a JSON compilation database (`compile_commands.json`) for Clang tooling.
*   **Compilation Database:** A structured JSON file recording exact compiler flags, working directories, and files used during a build.
*   **Ctags:** A tool that indexes language objects (functions, macros, structs) into a `tags` file for text-editor jump navigation.
*   **LSP:** Language Server Protocol. A standardized protocol between development tools and language analyzers (e.g., `clangd`).

## References
*   [arc42](https://arc42.org) - Architecture communication template.
*   [Bear](https://github.com/rizsotto/Bear) - Compilation database generator referenced in §2, §4, §6.2, §8, §9, §12.
*   [clangd](https://clangd.llvm.org) - Language server referenced in §1, §2, §4, §8, §9, §12.
*   [EditorConfig](https://editorconfig.org) - Cross-editor formatting specifications referenced in §5, §8.
*   [GNU Debugger (GDB)](https://www.gnu.org/software/gdb/) - Debugger referenced in §2, §8.
*   [ISO/IEC 9899:2011 (C11)](https://www.iso.org/standard/57853.html) - Language standard referenced in §2.
*   [Universal Ctags](https://ctags.io) - Source code indexer referenced in §2, §4, §6.2, §8, §12.
