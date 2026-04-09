# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-04-09

### Added

- `create` command — generate Flutter projects with Clean Architecture
- `feature` command — scaffold 3-layer features (full or flat)
- `add`/`remove` commands — manage 25 built-in modules
- `gen` command — code generation pipeline (build_runner + format)
- `eval` command — test runner with optional coverage reporting
- `deploy` command — trigger CI/CD deployment via GitHub Actions
- `doctor` command — environment health check (Dart, Flutter, Mason)
- `brick` command — community Mason brick management (add/remove/list)
- `init` command — add agentic_base to existing Flutter projects
- `upgrade` command — dependency upgrade with version tracking
- 3 state management options: Cubit (default), Riverpod, MobX
- Full Material 3 theme generation with 19 component themes
- CI/CD workflow templates (GitHub Actions + Fastlane)
- `AGENTS.md` + `CLAUDE.md` generation for AI agent integration
- 25 built-in modules across 6 categories: Core, Communication, Monetization, Media, Location, Device
