# CLAUDE.md — Agent Rules for SwiftApp-MacOS-Base-Model

## Navigation Rule (mandatory, every task)

Before writing code, making changes, or taking any decision:

1. **Read `AI_PROJECT_MAP.md` first** — it is the single source of truth for what exists, where it lives, and what each file does.
2. **Go directly to the relevant file(s)** — use the map to identify the exact file you need. Do not scan, list, or read files that are unrelated to the task.
   - Design/visual change → read the specific view file (e.g. `ActivationTab.swift`, `TitleBar.swift`)
   - State/logic change → read `AppState.swift` or `PanelController.swift`
   - New screen → read the map's Screens section for the pattern, then create following the same structure
   - Settings feature → go to `Screens/Settings/` directly
3. **Never read all files.** Only read what you will change or what you need to understand a dependency.

## After structural changes

When you create, move, rename, or delete any file or directory, update `AI_PROJECT_MAP.md` to reflect the change before finishing the task.
