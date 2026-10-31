# Working on OmniShell

## Purpose

Build a modular Roblox Studio project with selectable operating-system and console interfaces, then independently implemented playable experiences. The owner currently intends to run it locally in Studio.

## Organization

- `src/client/`: launcher, client navigation, and display code.
- `src/shared/`: platform catalogs and shared modules; everything here is visible to clients.
- `src/server/`: authoritative gameplay code as needed.
- `docs/`: architecture, roadmap, decisions, and current development state.
- `assets/`: source assets and provenance notes. Do not commit large binaries or extracted commercial game files by default.
- `work/`: ignored scratch files and temporary experiments.

## Workflow

1. Read `docs/STATUS.md` and relevant source before changing anything.
2. Keep source compatible with the Rojo project mapping in `default.project.json`.
3. Keep unfinished platforms visibly marked as planned or prototype. Never describe mock loading text as real hardware or operating-system initialization.
4. Preserve the owner's scope: a launcher is not a complete operating system, emulator, or full game port. Assess each requested compatibility feature independently.
5. Record meaningful architectural decisions in `docs/DECISIONS.md`; update `docs/STATUS.md` after substantial work with actual checks and remaining work.
6. Use Russian for owner-facing documentation and English for code identifiers.
7. Never claim Roblox Studio testing unless Studio was actually used. Separate build validation, static checks, and runtime checks.
8. Do not store credentials, personal data, or invented claims of persistent model learning. Documentation is project memory for future sessions.
9. Keep implementation simple; split platform-specific behavior into modules when it is actually introduced. Do not create empty systems or speculative abstractions.
10. The owner works on this computer during development. Run builds and logic checks in the background. Do not activate Studio, switch desktops, or use the shared mouse/keyboard while the owner is working; arrange an isolated environment or an agreed time for visual checks.
11. The owner requested a permanent build folder: `D:\Omni-Shell`. Use `scripts/build.ps1` for releases: it updates `D:\Omni-Shell\OmniShell.rbxlx` and keeps timestamped copies in `D:\Omni-Shell\builds`. Keep the stable filename and preserve old builds. Source code remains in this Git repository.

The owner's task instructions take precedence over these repository conventions.
