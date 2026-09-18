# Shared debug/developer tool discovery

`discover-debug-tools.ps1` is the generic, non-mutating Windows tool-discovery helper used by normal development/debugging workflows and by the Windows security-audit installer.

It does **not** install packages, download tools, edit PATH, or change debugger/system state.

## Outputs

By default it writes machine-local evidence under:

```text
%LOCALAPPDATA%\LLMDebugTools\debug-tool-manifest.json
%LOCALAPPDATA%\LLMDebugTools\debug-tool-warnings.txt
%LOCALAPPDATA%\LLMDebugTools\debug-tool-availability.md
```

The output root can be overridden with `-OutputRoot`. The security-audit installer passes its own install root, so a security-tooling run normally produces a sibling generic manifest such as:

```text
%LOCALAPPDATA%\SecurityAuditTools\debug-tool-manifest.json
%LOCALAPPDATA%\SecurityAuditTools\security-audit-tool-manifest.json
```

The first file owns generic debugger/developer paths. The second owns security-audit installation/scanner evidence.

The generic manifest also includes a `windows_sdk_debugger_architectures` matrix so architecture-specific SDK copies are visible independently instead of being hidden behind only the host-preferred result.

## Where paths come from

For Windows SDK Debugging Tools such as `cdb.exe`, `windbg.exe`, `dumpchk.exe`, `symchk.exe`, `dbh.exe`, `pdbcopy.exe`, `symstore.exe`, `gflags.exe`, and `umdh.exe`, discovery checks:

1. architecture-specific roots from `tool-paths.env` or same-named process environment variables;
2. standard Windows SDK roots derived from `ProgramFiles(x86)` and `ProgramFiles`;
3. `PATH` / `Get-Command`.

The architecture override variables are:

```text
WINDOWS_SDK_DEBUGGERS_X86
WINDOWS_SDK_DEBUGGERS_X64
WINDOWS_SDK_DEBUGGERS_ARM
WINDOWS_SDK_DEBUGGERS_ARM64
```

Standard SDK candidates are generated as:

```text
<ProgramFiles root>\Windows Kits\10\Debuggers\<arch>\<tool>
```

For example:

```text
C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\cdb.exe
C:\Program Files (x86)\Windows Kits\10\Debuggers\x86\cdb.exe
```

The normal `results` array remains backward-compatible and records the preferred available copy for each SDK tool. The architecture matrix separately reports x64, x86, ARM64, and ARM availability for every tracked SDK debugger utility.

MSVC tools use `MSVC_TOOLS_X86`, `MSVC_TOOLS_X64`, and `MSVC_TOOLS_ARM64` overrides first, then additional local roots, Visual Studio/vswhere discovery, and finally PATH. Host/target variants are preferred according to the current processor architecture.

LLVM, Sysinternals, and FFmpeg can be rooted with `LLVM_ROOT`, `SYSINTERNALS_ROOT`, and `FFMPEG_ROOT`. Additional managed roots supplied by a caller are searched before ordinary PATH fallback. When `%LOCALAPPDATA%\SecurityAuditTools\bin` exists, standalone discovery also adds it automatically, so tools installed by the security-audit installer (for example its managed FFmpeg build) remain discoverable without manually passing `-AdditionalToolRoots`.

## Local overrides

Copy or merge `common-tools/tool-paths.example.env` into the project's local `tool-paths.env`.

Relative paths are resolved against `-ProjectRoot`. The file is parsed as data only; it is not executed.

## Integrated-project location

The default project integration places this helper at:

```text
tools/discover-debug-tools.ps1
```

A typical non-mutating run is:

```powershell
.\tools\discover-debug-tools.ps1 -ProjectRoot .
```

Use the generated `debug-tool-manifest.json` as the first machine-specific source of truth for generic debugger/developer paths. Keep reusable `llm-wiki/debug-tools.md` guidance generic unless the repository intentionally tracks machine-specific locations.
