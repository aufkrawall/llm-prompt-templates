# Changelog

## Unreleased

### Improved

- **Economical diagnostics:** clarified that debug/diagnostic logging must stay economical to consume — single-line entries, log each distinct event once, rate-limit repeats with counters, cap and truncate collections and long values, verbose detail behind a flag.
- **Test-app and computer-use lifecycle:** prefer scripted, API-, CLI-, or harness-driven verification including scripted input and screenshots over interactive computer use; keep runs short and bounded with explicit stop conditions; shut down everything started including child processes and confirm nothing lingers; start interdependent apps in dependency order gated on readiness signals.
- **Reviewable commits:** commit messages use a concise title plus a short bullet-point body for non-trivial changes; prefer a series of small self-contained commits that each hold together and pass verification and secret-leak checks.
