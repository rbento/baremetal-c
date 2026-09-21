# baremetal-c

A minimal C project template for native Linux systems programming.

## 1. Introduction and Goals

`baremetal-c` is a starter template for Linux C development: an isolated directory layout, a direct POSIX Makefile, out-of-source builds, and automated tooling generation for lightweight editor environments.

```bash
git clone https://github.com/<user>/baremetal-c.git my-project
cd my-project
./bootstrap.sh
make run
```

**Primary Goals:**
*   **Artifact Isolation:** Strictly separate build outputs from the source tree.
*   **Editor Agnosticism:** Integrate seamlessly with lightweight editors (Vim, Emacs) via standard CLI tooling (`clangd`, `ctags`, `bear`).
*   **Minimalist Toolchain:** Avoid heavy meta-build abstraction layers by relying directly on POSIX `make` and explicit compiler flags.

## 2. Architecture Constraints
*   **Target OS:** Linux (hosted environment).
*   **Language Standard:** ISO C11.
*   **Compiler:** `clang` (default) or `gcc`.
*   **Build System:** POSIX `make`.
*   **Debugger:** `gdb`.
*   **Tooling:** `bear` (compilation database), `ctags` (source indexing), `clangd` (LSP).

## 3. System Scope and Context
*   **Context:** The template serves as a minimal starting point for hosted Linux userland utilities and systems tools (no third-party runtime frameworks).
*   **Technical Scope:** The pipeline consumes `.c` and `.h` source files, runs them through POSIX `make`, generates native Linux ELF executables in `build/bin/`, and exports editor metadata (`compile_commands.json`, `tags`).

## 4. Solution Strategy
*   **Out-of-source compilation:** Object files (`.o`), dependency files (`.d`), and executables route exclusively to a transient `build/` tree to keep the repository root clean.
*   **Header Dependency Tracking:** Compiler flags (`-MMD -MP`) generate Make prerequisites during compilation, ensuring proper recompilation when included headers change.
*   **Automated Tooling Sync:** `bootstrap.sh` automates the generation of `compile_commands.json` and tag indexes so editor LSP diagnostics and navigation match the current build state.

## 5. Building Block View
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

## 6. Runtime View
### 6.1 Standard Build Sequence
1.  `make` is executed.
2.  The compiler compiles modified `.c` files in `src/` into `.o` objects in `build/obj/`.
3.  The compiler writes header dependency `.d` files alongside object files in `build/obj/`.
4.  The linker combines all `.o` objects into the final binary inside `build/bin/`.

### 6.2 Environment Bootstrap Sequence (`bootstrap.sh`)
1.  Invokes `make clean` to purge existing build artifacts.
2.  Removes stale caches and editor indexes (`.cache`, `.clangd`, `tags`, `compile_commands.json`).
3.  Executes `bear -- make debug` to run a debug build (`-g -O0 -DDEBUG`) while capturing compiler invocations into `compile_commands.json`.
4.  Runs `ctags -R .` to index function signatures and identifiers for tag-based navigation.
5.  Prints the output paths of all generated artifacts.

## 8. Cross-cutting Concepts
*   **Editor Integration:** Standard CLI tools (`bear`, `ctags`) are preferred over IDE-specific extensions. Any editor implementing LSP (`clangd`) or tags gets jump-to-definition, code completion, and diagnostics out of the box.
*   **Code Style Enforcement:** `.clang-format` handles syntax layout deterministically to prevent diff noise. `.editorconfig` provides basic whitespace settings for environments without an active LSP.
*   **Debugging Instrumentation:** The `make debug` target applies `-g -O0 -DDEBUG` so `gdb` retains full DWARF symbol tables and avoids instruction reordering during stepping.

## 9. Architecture Decisions
*   **ADR-01: Artifact Segregation:** Source directories must contain zero generated files. *Rationale:* Prevents clutter, simplifies `.gitignore`, and eliminates accidental binary check-ins.
*   **ADR-02: POSIX Make over CMake:** Direct Makefiles are chosen over CMake or Meson. *Rationale:* Eliminates meta-build dependencies, keeps the build process transparent, and avoids unnecessary abstractions for small-to-medium C projects.
*   **ADR-03: Bear for LSP Support:** `bear` is used to intercept `make` rather than migrating the project to CMake solely for `CMAKE_EXPORT_COMPILE_COMMANDS`. *Rationale:* Retains the simplicity of a raw Makefile while maintaining full `clangd` language server support.

## 12. Glossary
*   **Bear:** A build-interception tool that generates a JSON compilation database (`compile_commands.json`) for Clang tooling.
*   **Compilation Database:** A structured JSON file recording exact compiler flags, working directories, and files used during a build.
*   **Ctags:** A tool that indexes language objects (functions, macros, structs) into a `tags` file for text-editor jump navigation.
*   **LSP:** Language Server Protocol. A standardized protocol between development tools and language analyzers (e.g., `clangd`).

---

## References
*   [arc42](https://arc42.org) — Architecture communication template.
*   [Bear](https://github.com/rizsotto/Bear) — Compilation database generator referenced in §2, §4, §6.2, §8, §9, §12.
*   [clangd](https://clangd.llvm.org) — Language server referenced in §1, §2, §4, §8, §9, §12.
*   [EditorConfig](https://editorconfig.org) — Cross-editor formatting specifications referenced in §5, §8.
*   [GNU Debugger (GDB)](https://www.gnu.org/software/gdb/) — Debugger referenced in §2, §8.
*   [ISO/IEC 9899:2011 (C11)](https://www.iso.org/standard/57853.html) — Language standard referenced in §2.
*   [Universal Ctags](https://ctags.io) — Source code indexer referenced in §2, §4, §6.2, §8, §12.
