<!--
SPDX-License-Identifier: MIT
Copyright (c) 2026 aufkrawall
-->

# Debug and Binary Analysis Tools

This file is a reusable project-local tool inventory. Record tools and project-specific paths here when copying the template into a repository. Treat documented paths as hints until verified on the current machine.

## General rules

- Verify that a tool exists and runs before relying on it.
- Prefer repository-pinned or project-local tools when available.
- Prefer discovery (`Get-Command`, `where.exe`, `command -v`, tool manifests, environment variables) over stale hardcoded paths.
- Treat dumps, logs, captures, symbols, extracted strings, and diagnostic output as potentially sensitive.
- Do not mutate binaries, symbols, global debugger flags, registry/system settings, or persistent runtime configuration unless explicitly requested.
- When a preferred tool is unavailable, use a safe equivalent when practical and record the resulting coverage limitation.

## Project path variables

Projects may define equivalent variables in a local, uncommitted environment file:

```text
PROJECT_ROOT=
BUILD_ROOT=
INSTALL_ROOT=
SYMBOL_ROOT=
LOG_ROOT=
DUMP_ROOT=
CAPTURE_ROOT=
```

Use project-specific names if the repository already has established conventions.

## Windows debugging and binary analysis

Common tools, when installed:

| Tool | Purpose |
| --- | --- |
| `cdb.exe` | Command-line crash-dump debugging and stack inspection |
| `windbg.exe` / `WinDbgX.exe` | Interactive crash-dump and live debugging |
| `dumpchk.exe` | Dump readability and metadata validation |
| `symchk.exe` | Symbol validation/download |
| `dbh.exe` | PDB/symbol inspection |
| `pdbcopy.exe` / `symstore.exe` | Symbol-file handling and stores |
| `dumpbin.exe` / `link.exe /dump` | PE/COFF headers, imports, exports, sections, load config |
| `lib.exe /list` | Static-library member inspection |
| `undname.exe` | MSVC C++ symbol undecoration |
| `llvm-objdump.exe` | Object/binary inspection and disassembly |
| `llvm-strings.exe` / `strings.exe` | Printable-string inspection |
| `procdump.exe` | Process dump capture |
| `procmon.exe` | Process, registry, filesystem, and network activity tracing |
| `procexp.exe` | Process, handle, DLL, and thread inspection |
| `vmmap.exe` | Virtual-memory layout inspection |
| `handle.exe` | Open-handle inspection |
| `listdlls.exe` | Loaded-module inspection |
| `sigcheck.exe` | Signatures, versions, hashes, and related metadata |

Typical discovery commands:

```powershell
Get-Command cdb, windbg, dumpbin, llvm-objdump, procdump, procmon, sigcheck -ErrorAction SilentlyContinue
where.exe cdb.exe
where.exe dumpbin.exe
```

For crash dumps, use both public symbol servers and the relevant local/project symbol directory when local symbols are required. Example:

```powershell
cdb -z "$env:DUMP_ROOT\crash.dmp" -y "srv*;$env:SYMBOL_ROOT" -c ".ecxr; k; q"
```

Do not copy this command blindly: resolve the actual dump and symbol paths first.

## Linux debugging and binary analysis

Common tools:

| Tool | Purpose |
| --- | --- |
| `gdb` / `lldb` | Debugging and core analysis |
| `file` | Architecture and ABI identification |
| `readelf` | ELF headers, sections, symbols, program headers, dynamic metadata |
| `objdump` / `llvm-objdump` | Headers, disassembly, imports, sections |
| `nm` / `llvm-nm` | Symbol inspection |
| `strings` / `llvm-strings` | Embedded string inspection |
| `patchelf --print-rpath` | RPATH/RUNPATH inspection |
| `checksec` | Hardening summary |
| `strace` | Syscall tracing |

Prefer `readelf -d`, `objdump -p`, or equivalent static inspection for untrusted binaries. Use `ldd` only for trusted local build artifacts because loader-based dependency inspection can execute code in unsafe circumstances.

## macOS debugging and binary analysis

Common tools:

| Tool | Purpose |
| --- | --- |
| `lldb` | Debugging and crash analysis |
| `file` | Architecture and Mach-O identification |
| `otool` | Load commands and linked-library inspection |
| `lipo` | Universal-binary slice inspection |
| `codesign` | Signature, entitlement, and hardened-runtime metadata |
| `dwarfdump` | dSYM/debug-info inspection |
| `nm` / `strings` | Symbol and string inspection |
| `log` | Unified log inspection |
| `fs_usage` / `dtruss` | Runtime tracing where permitted |

For universal binaries, inspect each relevant architecture slice independently when architecture-specific behavior matters.

## Project-specific additions

Add only durable project-specific diagnostics here, such as:

- exact local symbol locations or discovery rules
- known-good debugger commands
- project-specific log/capture paths
- domain-specific diagnostic tools
- artifact inspection commands
- special environment flags used only for diagnosis

Keep incident-specific timelines and temporary findings in `llm-wiki/log/recent.md` rather than turning this file into a historical dump.
