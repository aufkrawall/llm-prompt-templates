#!/usr/bin/env sh
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 aufkrawall

# install-security-audit-tools.sh
#
# Conservative Linux/macOS security-audit tool detector and optional small-tool installer.
#
# Defaults:
# - Does not install anything unless --install-small is provided.
# - Detects SAST, secrets, dependency, binary, and runtime inspection tools.
# - Writes manifest JSON, warnings text, and Markdown availability report.
# - Avoids large packages by default.
# - Prefers package manager tools where already installed.
# - Uses safe, project-documented sources for optional portable downloads where practical.
#
# Intended repo location:
#   install-security-audit-tools.sh

set -u

INSTALL_ROOT="${SECURITY_AUDIT_TOOL_ROOT:-$HOME/.local/security-audit-tools}"
DOC_PATH="./llm-wiki/debug-tools-security-audit.md"
INSTALL_SMALL=0
ADD_TO_PATH=0
WHATIF=0
INCLUDE_SEMGREP=0
INCLUDE_TRUFFLEHOG=0
INCLUDE_FLAWFINDER=0
INCLUDE_OSV=0
INCLUDE_GITLEAKS=0

usage() {
  cat <<'USAGE'
Usage: ./install-security-audit-tools.sh [options]

Options:
  --install-root DIR       Install/detect output root. Default: ~/.local/security-audit-tools
  --doc PATH               Path to debug-tools-security-audit.md or debug-tools.md
  --install-small          Download/install selected smaller tools where practical
  --include-semgrep        Install semgrep via pipx/pip if possible (opt-in)
  --include-flawfinder     Install flawfinder via pipx/pip if possible (opt-in)
  --include-gitleaks       Download gitleaks portable binary from official GitHub release (opt-in)
  --include-osv-scanner    Download osv-scanner portable binary from official GitHub release (opt-in)
  --include-trufflehog     Download trufflehog portable binary from official GitHub release (opt-in)
  --add-to-path            Print PATH export line for installed tool bin directory
  --what-if                Print actions without downloading/installing
  -h, --help               Show help

Default behavior only detects tools and writes evidence.

Outputs:
  $INSTALL_ROOT/security-audit-tool-manifest.json
  $INSTALL_ROOT/security-audit-tool-warnings.txt
  $INSTALL_ROOT/security-audit-tool-availability.md
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --install-root) INSTALL_ROOT="$2"; shift 2 ;;
    --doc) DOC_PATH="$2"; shift 2 ;;
    --install-small) INSTALL_SMALL=1; shift ;;
    --include-semgrep) INCLUDE_SEMGREP=1; shift ;;
    --include-flawfinder) INCLUDE_FLAWFINDER=1; shift ;;
    --include-gitleaks) INCLUDE_GITLEAKS=1; shift ;;
    --include-osv-scanner) INCLUDE_OSV=1; shift ;;
    --include-trufflehog) INCLUDE_TRUFFLEHOG=1; shift ;;
    --add-to-path) ADD_TO_PATH=1; shift ;;
    --what-if) WHATIF=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 64 ;;
  esac
done

BIN_DIR="$INSTALL_ROOT/bin"
LOG_DIR="$INSTALL_ROOT/logs"
MANIFEST="$INSTALL_ROOT/security-audit-tool-manifest.json"
WARNINGS="$INSTALL_ROOT/security-audit-tool-warnings.txt"
MD="$INSTALL_ROOT/security-audit-tool-availability.md"

RESULTS_FILE="$INSTALL_ROOT/.results.tsv"
: > "$RESULTS_FILE" 2>/dev/null || true
WARN_FILE_TMP="$INSTALL_ROOT/.warnings.tmp"

mkdir -p "$BIN_DIR" "$LOG_DIR" 2>/dev/null || {
  echo "ERROR: cannot create install root: $INSTALL_ROOT" >&2
  exit 1
}
: > "$RESULTS_FILE"
: > "$WARN_FILE_TMP"

warn() {
  msg="$1"
  echo "WARNING: $msg" >&2
  echo "$msg" >> "$WARN_FILE_TMP"
}

json_escape() {
  # Minimal JSON string escaping for evidence output.
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g'
}

add_result() {
  name="$1"
  category="$2"
  status="$3"
  path="${4:-}"
  source="${5:-}"
  notes="${6:-}"
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$name" "$category" "$status" "$path" "$source" "$notes" >> "$RESULTS_FILE"
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

cmd_path() {
  command -v "$1" 2>/dev/null || true
}

tool_version() {
  tool="$1"
  shift
  if has_cmd "$tool"; then
    "$tool" "$@" 2>/dev/null | head -n 1 | tr '\n' ' '
  fi
}

sha256_file() {
  f="$1"
  if has_cmd sha256sum; then sha256sum "$f" | awk '{print $1}'; return; fi
  if has_cmd shasum; then shasum -a 256 "$f" | awk '{print $1}'; return; fi
  if has_cmd openssl; then openssl dgst -sha256 "$f" | awk '{print $NF}'; return; fi
  echo ""
}

download() {
  url="$1"
  out="$2"
  if [ "$WHATIF" -eq 1 ]; then
    echo "Would download $url -> $out"
    return 0
  fi
  mkdir -p "$(dirname "$out")"
  if has_cmd curl; then
    curl -fsSL "$url" -o "$out"
  elif has_cmd wget; then
    wget -q "$url" -O "$out"
  else
    warn "curl/wget unavailable; cannot download $url"
    return 1
  fi
}

detect_tool() {
  name="$1"
  category="$2"
  version_args="${3:---version}"
  if has_cmd "$name"; then
    p="$(cmd_path "$name")"
    v="$(tool_version "$name" $version_args)"
    add_result "$name" "$category" "available" "$p" "" "$v"
    return 0
  fi
  add_result "$name" "$category" "missing" "" "" ""
  return 1
}

detect_doc() {
  if [ -f "$DOC_PATH" ]; then
    add_result "debug-tools doc" "local guidance" "available" "$DOC_PATH" "" ""
    return
  fi

  for p in ./llm-wiki/debug-tools-security-audit.md ./llm-wiki/debug-tools.md ./debug-tools-security-audit.md ./debug-tools.md; do
    if [ -f "$p" ]; then
      add_result "debug-tools doc" "local guidance" "available" "$p" "" "fallback"
      DOC_PATH="$p"
      return
    fi
  done

  warn "No debug-tools-security-audit.md or debug-tools.md found; local project-specific tool guidance is unavailable."
  add_result "debug-tools doc" "local guidance" "missing" "" "" ""
}

detect_platform_tools() {
  uname_s="$(uname -s 2>/dev/null || echo unknown)"
  uname_m="$(uname -m 2>/dev/null || echo unknown)"
  add_result "host" "platform" "detected" "" "" "$uname_s $uname_m"

  # Common SAST / secrets / deps
  detect_tool semgrep "SAST" "--version" || warn "semgrep unavailable; source-level SAST confidence may be reduced where applicable."
  detect_tool flawfinder "SAST C/C++" "--version" || warn "flawfinder unavailable; C/C++ risky API scan confidence may be reduced where applicable."
  detect_tool gitleaks "secrets" "version" || warn "gitleaks unavailable; secrets-scanning confidence may be reduced where applicable."
  detect_tool trufflehog "secrets" "--version" || warn "trufflehog unavailable; deeper secrets scanning unavailable."
  detect_tool osv-scanner "dependency" "--version" || warn "osv-scanner unavailable; dependency vulnerability coverage may be reduced where applicable."
  detect_tool cargo-audit "dependency Rust" "--version" >/dev/null 2>&1 || add_result "cargo-audit" "dependency Rust" "missing" "" "" "only applicable for Rust projects"
  detect_tool npm "dependency Node" "--version" >/dev/null 2>&1 || add_result "npm" "dependency Node" "missing" "" "" "only applicable for Node projects"
  detect_tool pip-audit "dependency Python" "--version" >/dev/null 2>&1 || add_result "pip-audit" "dependency Python" "missing" "" "" "only applicable for Python projects"
  detect_tool govulncheck "dependency Go" "-version" >/dev/null 2>&1 || add_result "govulncheck" "dependency Go" "missing" "" "" "only applicable for Go projects"

  # Common binary/runtime
  detect_tool file "binary inspection" "--version" || warn "file unavailable; architecture/ABI detection coverage reduced."
  detect_tool strings "binary inspection" "--version" || warn "strings unavailable; embedded-string/secrets binary scan coverage reduced."
  detect_tool nm "binary inspection" "--version" >/dev/null 2>&1 || add_result "nm" "binary inspection" "missing" "" "" ""
  detect_tool objdump "binary inspection" "--version" >/dev/null 2>&1 || add_result "objdump" "binary inspection" "missing" "" "" ""
  detect_tool readelf "Linux ELF inspection" "--version" >/dev/null 2>&1 || add_result "readelf" "Linux ELF inspection" "missing" "" "" "Linux only"
  detect_tool checksec "Linux hardening" "--version" >/dev/null 2>&1 || add_result "checksec" "Linux hardening" "missing" "" "" "Linux only / optional"
  detect_tool patchelf "Linux ELF inspection" "--version" >/dev/null 2>&1 || add_result "patchelf" "Linux ELF inspection" "missing" "" "" "Linux only / optional"
  detect_tool strace "Linux runtime tracing" "-V" >/dev/null 2>&1 || add_result "strace" "Linux runtime tracing" "missing" "" "" "Linux only"
  detect_tool ltrace "Linux runtime tracing" "-V" >/dev/null 2>&1 || add_result "ltrace" "Linux runtime tracing" "missing" "" "" "Linux only"
  detect_tool gdb "debugger" "--version" >/dev/null 2>&1 || add_result "gdb" "debugger" "missing" "" "" "optional"
  detect_tool lldb "debugger" "--version" >/dev/null 2>&1 || add_result "lldb" "debugger" "missing" "" "" "optional"

  # macOS-specific
  if [ "$uname_s" = "Darwin" ]; then
    for t in codesign otool lipo dwarfdump spctl log fs_usage; do
      if has_cmd "$t"; then
        add_result "$t" "macOS inspection" "available" "$(cmd_path "$t")" "" ""
      else
        add_result "$t" "macOS inspection" "missing" "" "" ""
        warn "$t unavailable; macOS inspection coverage may be reduced."
      fi
    done
  fi
}

github_latest_url() {
  repo="$1"
  case "$repo" in
    gitleaks/gitleaks)
      os="$(uname -s | tr '[:upper:]' '[:lower:]')"
      arch="$(uname -m)"
      case "$arch" in
        x86_64|amd64) arch="x64" ;;
        aarch64|arm64) arch="arm64" ;;
      esac
      echo "https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks_${os}_${arch}.tar.gz"
      ;;
    google/osv-scanner)
      os="$(uname -s | tr '[:upper:]' '[:lower:]')"
      arch="$(uname -m)"
      case "$arch" in
        x86_64|amd64) arch="amd64" ;;
        aarch64|arm64) arch="arm64" ;;
      esac
      echo "https://github.com/google/osv-scanner/releases/latest/download/osv-scanner_${os}_${arch}"
      ;;
    trufflesecurity/trufflehog)
      os="$(uname -s | tr '[:upper:]' '[:lower:]')"
      arch="$(uname -m)"
      case "$arch" in
        x86_64|amd64) arch="amd64" ;;
        aarch64|arm64) arch="arm64" ;;
      esac
      echo "https://github.com/trufflesecurity/trufflehog/releases/latest/download/trufflehog_${os}_${arch}.tar.gz"
      ;;
  esac
}

install_python_tool() {
  tool="$1"
  package="$2"

  if has_cmd "$tool"; then
    return 0
  fi

  if [ "$WHATIF" -eq 1 ]; then
    echo "Would install $package for $tool using pipx or pip --user"
    return 0
  fi

  if has_cmd pipx; then
    pipx install "$package" || {
      warn "pipx install failed for $package"
      return 1
    }
    return 0
  fi

  if has_cmd python3; then
    python3 -m pip install --user "$package" || {
      warn "python3 -m pip install --user failed for $package"
      return 1
    }
    return 0
  fi

  warn "Neither pipx nor python3 is available; cannot install $package"
  return 1
}

install_gitleaks() {
  if has_cmd gitleaks; then return 0; fi
  url="$(github_latest_url gitleaks/gitleaks)"
  out="$BIN_DIR/gitleaks.tar.gz"
  download "$url" "$out" || return 1
  if [ "$WHATIF" -eq 0 ]; then
    tar -xzf "$out" -C "$BIN_DIR" gitleaks 2>/dev/null || tar -xzf "$out" -C "$BIN_DIR"
    chmod +x "$BIN_DIR/gitleaks" 2>/dev/null || true
    hash="$(sha256_file "$BIN_DIR/gitleaks")"
    add_result "gitleaks" "secrets" "installed" "$BIN_DIR/gitleaks" "$url" "SHA256=$hash"
  fi
}

install_osv_scanner() {
  if has_cmd osv-scanner; then return 0; fi
  url="$(github_latest_url google/osv-scanner)"
  out="$BIN_DIR/osv-scanner"
  download "$url" "$out" || return 1
  if [ "$WHATIF" -eq 0 ]; then
    chmod +x "$out"
    hash="$(sha256_file "$out")"
    add_result "osv-scanner" "dependency" "installed" "$out" "$url" "SHA256=$hash"
  fi
}

install_trufflehog() {
  if has_cmd trufflehog; then return 0; fi
  url="$(github_latest_url trufflesecurity/trufflehog)"
  out="$BIN_DIR/trufflehog.tar.gz"
  download "$url" "$out" || return 1
  if [ "$WHATIF" -eq 0 ]; then
    tar -xzf "$out" -C "$BIN_DIR" trufflehog 2>/dev/null || tar -xzf "$out" -C "$BIN_DIR"
    chmod +x "$BIN_DIR/trufflehog" 2>/dev/null || true
    hash="$(sha256_file "$BIN_DIR/trufflehog")"
    add_result "trufflehog" "secrets" "installed" "$BIN_DIR/trufflehog" "$url" "SHA256=$hash"
  fi
}

maybe_install_small() {
  if [ "$INSTALL_SMALL" -eq 0 ]; then
    warn "Install mode was not enabled. No tools were installed; detection-only evidence was generated."
    return
  fi

  if [ "$INCLUDE_GITLEAKS" -eq 1 ]; then install_gitleaks; fi
  if [ "$INCLUDE_OSV" -eq 1 ]; then install_osv_scanner; fi
  if [ "$INCLUDE_TRUFFLEHOG" -eq 1 ]; then install_trufflehog; fi
  if [ "$INCLUDE_SEMGREP" -eq 1 ]; then install_python_tool semgrep semgrep; fi
  if [ "$INCLUDE_FLAWFINDER" -eq 1 ]; then install_python_tool flawfinder flawfinder; fi

  if [ "$INCLUDE_GITLEAKS" -eq 0 ] && [ "$INCLUDE_OSV" -eq 0 ] && [ "$INCLUDE_TRUFFLEHOG" -eq 0 ] && [ "$INCLUDE_SEMGREP" -eq 0 ] && [ "$INCLUDE_FLAWFINDER" -eq 0 ]; then
    warn "--install-small was set, but no specific install flags were provided. Nothing was installed."
  fi
}

write_outputs() {
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date)"
  os_name="$(uname -s 2>/dev/null || echo unknown)"
  arch_name="$(uname -m 2>/dev/null || echo unknown)"

  if [ "$WHATIF" -eq 1 ]; then
    echo "What-if mode: not writing outputs."
    return
  fi

  {
    echo "{"
    echo "  \"generated_at\": \"$(json_escape "$now")\","
    echo "  \"install_root\": \"$(json_escape "$INSTALL_ROOT")\","
    echo "  \"host\": {\"os\": \"$(json_escape "$os_name")\", \"arch\": \"$(json_escape "$arch_name")\"},"
    echo "  \"results\": ["
    first=1
    while IFS="$(printf '\t')" read -r name category status path source notes; do
      [ -n "$name" ] || continue
      if [ "$first" -eq 0 ]; then echo ","; fi
      first=0
      printf '    {"name":"%s","category":"%s","status":"%s","path":"%s","source":"%s","notes":"%s"}' \
        "$(json_escape "$name")" "$(json_escape "$category")" "$(json_escape "$status")" "$(json_escape "$path")" "$(json_escape "$source")" "$(json_escape "$notes")"
    done < "$RESULTS_FILE"
    echo ""
    echo "  ],"
    echo "  \"warnings\": ["
    first=1
    while IFS= read -r w; do
      [ -n "$w" ] || continue
      if [ "$first" -eq 0 ]; then echo ","; fi
      first=0
      printf '    "%s"' "$(json_escape "$w")"
    done < "$WARN_FILE_TMP"
    echo ""
    echo "  ]"
    echo "}"
  } > "$MANIFEST"

  cp "$WARN_FILE_TMP" "$WARNINGS"

  {
    echo "# Security Audit Tool Availability"
    echo
    echo "- Generated: $now"
    echo "- Install root: \`$INSTALL_ROOT\`"
    echo "- Host: $os_name $arch_name"
    echo
    echo "## Warnings"
    echo
    if [ ! -s "$WARN_FILE_TMP" ]; then
      echo "- None"
    else
      while IFS= read -r w; do
        [ -n "$w" ] && echo "- WARNING: $w"
      done < "$WARN_FILE_TMP"
    fi
    echo
    echo "## Tool results"
    echo
    echo "| Tool | Category | Status | Path | Source | Notes |"
    echo "|---|---|---|---|---|---|"
    while IFS="$(printf '\t')" read -r name category status path source notes; do
      [ -n "$name" ] || continue
      echo "| $name | $category | $status | \`$path\` | $source | $notes |"
    done < "$RESULTS_FILE"
  } > "$MD"

  echo "Wrote $MANIFEST"
  echo "Wrote $WARNINGS"
  echo "Wrote $MD"

  if [ "$ADD_TO_PATH" -eq 1 ]; then
    echo
    echo "Add this to your shell profile if desired:"
    echo "export PATH=\"$BIN_DIR:\$PATH\""
  fi
}

detect_doc
detect_platform_tools
maybe_install_small
# Re-detect after optional install.
detect_platform_tools
write_outputs

if [ -s "$WARN_FILE_TMP" ]; then
  echo "Completed with warnings. Reflect these in audit confidence/scoring." >&2
  exit 2
fi

echo "Completed without warnings."
exit 0
