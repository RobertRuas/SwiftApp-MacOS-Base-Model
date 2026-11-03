# SwiftApp-MacOS-Base-Model — File & Directory Map

> Reference for AI agents. Every file and directory in this project with its exact purpose, contents, and relationships.

## Project Overview

- **What**: Native macOS utility app — a floating panel anchored to the right edge of the screen
- **Stack**: Swift 6.4, SwiftUI + AppKit hybrid, Swift Package Manager (no Xcode project)
- **Target**: macOS 26+
- **Language mode**: Swift 5 (set in Package.swift to avoid strict concurrency; SwiftUIMacros plugin is NOT available — `@State`, `@Binding`, `@Environment` cannot be used)
- **Observation**: Uses `@Observable` from the Observation framework (ObservationMacros IS available). All bindings are created manually via `Binding(get:set:)`.
- **No Dock icon**: Runs as `.accessory` activation policy — no menu bar, no Dock presence
- **Window type**: `NSPanel` with `.borderless` + `.nonactivatingPanel` — floats above all apps without stealing focus

---

## Root Files

```
SwiftApp-MacOS-Base-Model/
├── Package.swift              SPM manifest. swift-tools-version:6.2, target macOS .v26, language mode .v5. Single executable target "SwiftApp-MacOS-Base-Model" with path "Sources". Depends on sparkle-project/Sparkle (from 2.6.4). linkerSettings add -rpath @executable_path and @executable_path/../Frameworks so the Sparkle.framework resolves both from .build/debug (local dev) and from Contents/Frameworks (packaged .app).
├── Package.resolved           Pins the resolved Sparkle version. Scripts/build_appcast.sh and Scripts/generate_sparkle_keys.sh read this to download matching Sparkle CLI tools.
├── dev.sh                     Hot reload script. On start, kills any already-running SwiftApp-MacOS-Base-Model instance (even from a previous/untracked session) before the first build. Uses fswatch to watch Sources/ recursively. On file change: kills running app → swift build → relaunch. Run with: bash dev.sh
├── .gitignore                 Ignores .build/, .swiftpm/, xcodeproj, DerivedData, .DS_Store, build/, dist/, .sparkle-tools/
└── AI_PROJECT_MAP.md          THIS FILE. Project map for AI agents.
```

## Releases & Auto-Update

```
.github/workflows/
└── release.yml                Triggers on push of tags matching v*.*.*. Builds release binary, packages SwiftApp-MacOS-Base-Model.app
                                (via Scripts/package_app.sh), signs it for Sparkle and generates the appcast
                                (via Scripts/build_appcast.sh), creates a GitHub Release with the .zip + appcast.xml,
                                then deletes every other release so only the latest stays published.
                                Needs repo secrets: SPARKLE_PRIVATE_KEY, SPARKLE_PUBLIC_KEY (see Scripts/generate_sparkle_keys.sh).

Packaging/
└── Info.plist                 Template Info.plist for the packaged app. Placeholders __VERSION__, __OWNER__, __REPO__,
                                __SPARKLE_PUBLIC_KEY__ are substituted by Scripts/package_app.sh.
                                SUFeedURL points to https://github.com/<owner>/<repo>/releases/latest/download/appcast.xml
                                (GitHub's stable "latest" redirect — always resolves to the one release kept published).
                                SUEnableAutomaticChecks + SUAutomaticallyUpdate are both true: updates download and
                                install automatically without prompting.

Scripts/
├── package_app.sh              Builds build/SwiftApp-MacOS-Base-Model.app from .build/release, embeds Sparkle.framework into
│                                Contents/Frameworks, fills in Packaging/Info.plist, ad-hoc codesigns (deep, including
│                                Sparkle's nested XPC services/Autoupdate/Updater.app), zips to dist/SwiftApp-MacOS-Base-Model-<version>.zip.
├── build_appcast.sh             Downloads the Sparkle CLI tools matching Package.resolved's pinned version, runs
│                                generate_appcast against dist/ to sign the zip (EdDSA) and emit dist/appcast.xml.
│                                Reads the private key from SPARKLE_PRIVATE_KEY (never written to disk outside a temp file).
└── generate_sparkle_keys.sh     Run locally (not in CI) once to generate the Sparkle EdDSA key pair via the official
                                 generate_keys tool. Private key goes to the login Keychain / GitHub secret
                                 SPARKLE_PRIVATE_KEY; public key goes into Packaging/Info.plist and GitHub secret
                                 SPARKLE_PUBLIC_KEY.
```

No code signing certificate / Apple Developer ID is configured yet — builds are ad-hoc signed only, so
first launch after download/update will show a Gatekeeper warning until a Developer ID is added later.

## Config

```
.vscode/
└── launch.json                VS Code Swift debugger configs (Debug + Release). Uses swift-extension launch type.
```

---

## Sources — Application Code

All Swift source files live under `Sources/`. SPM compiles every `.swift` file in this tree as a single target.

### Sources/App/ — Entry Point & Window Management

```
App/
├── MacroTicApp.swift          ENTRY POINT. @main enum SwiftAppBase with static func main().
│                              Creates NSApplication, sets .accessory policy (no Dock icon),
│                              assigns AppDelegate, calls app.run().
│                              AppDelegate creates and holds PanelController on launch.
│
├── UpdaterController.swift    SPARKLE WRAPPER. @Observable class wrapping SPUStandardUpdaterController.
│                              Starts the updater on init (startingUpdater: true). Exposes canCheckForUpdates
│                              and checkForUpdates() for UI (used by Settings' "Verificar atualizações" button).
│                              Actual update behavior (feed URL, automatic install, EdDSA key) comes entirely
│                              from Contents/Info.plist at runtime — see Packaging/Info.plist. No-ops quietly
│                              when run outside a packaged .app bundle (e.g. via dev.sh / .build/debug).
│
└── PanelController.swift      WINDOW CONTROLLER. @Observable class managing the NSPanel.
                               Properties:
                                 - isExpanded: Bool — panel open/closed state
                                 - tabHovering: Bool — mouse hover on activation tab
                                 - isPinned: Bool — anchored to edge vs freely draggable
                                 - state: AppState — app-wide settings (let, @ObservationIgnored)
                                 - panel: NSPanel? — the actual window (@ObservationIgnored)
                               Constants:
                                 - tabWidth: 24px — tab bump protrusion width
                                 - contentWidth: 344px — glass panel content area
                                 - panelWidth: 368px (tabWidth + contentWidth)
                                 - panelHeight: 420px — square-ish shape
                                 - topMargin: 60px — distance from top of visible frame
                                 - tabHeight: 80px — height of the tab bump handle
                               Methods:
                                 - toggle() — expand/collapse with animation
                                 - collapse() — close panel + reset settings view
                                 - togglePin() — switch between pinned/free-dragging
                               Animation: NSAnimationContext, 0.32s ease-in-out, slides panel x-position.
                               When collapsed: only tab visible at right edge of screen.
                               When expanded: full panel visible, anchored upper-right.
```

### Sources/Models/ — Data & State

```
Models/
└── AppState.swift             APP STATE. @Observable class with all user-facing settings.
                               Properties:
                                 - showSettings: Bool — toggles settings screen visibility
                                 - updater: UpdaterController — owns the Sparkle updater instance, passed to SettingsView
```

### Sources/Screens/ — Screen-level Views

Each screen has its own directory. Components specific to a screen go in its `Components/` subdirectory.

```
Screens/
├── Main/                      MAIN SCREEN — the root panel layout
│   ├── MainPanelView.swift    ROOT VIEW hosted by NSHostingView inside the NSPanel.
│   │                          HStack layout: SidePanel (left) + content VStack (right).
│   │                          Unified PanelShape(isExpanded: controller.isExpanded): .regularMaterial
│   │                          background + clip + stroke border — switches between the bump (collapsed)
│   │                          and flush rounded-rect (expanded) look, see Components/PanelShape.swift.
│   │                          Content VStack: TitleBar on top, then either SettingsView or empty.
│   │                          Animations: .easeInOut for expand, .spring for settings transition.
│   │
│   └── Components/
│       └── TitleBar.swift     TOP BAR inside the glass panel. 38px height.
│                              Left side: X button (calls controller.collapse()), pin/unpin toggle.
│                              Right side: gear icon (toggles state.showSettings).
│                              All buttons: .plain style, .secondary foreground.
│
└── Settings/                  SETTINGS SCREEN — shown inside the panel when gear icon is tapped
    └── SettingsView.swift     SETTINGS ROOT. ScrollView with GeneralSection + UpdatesSection.
                               GeneralSection: placeholder for future settings.
                               UpdatesSection: explains auto-update is automatic, has a "Verificar atualizações"
                               button calling state.updater.checkForUpdates() (see UpdaterController.swift).
```

### Sources/Components/ — Shared Reusable Components

```
Components/
├── PanelShape.swift           CUSTOM SHAPE. Takes `isExpanded: Bool` (default false).
│                              - isExpanded == false (collapsed): bumpPath — rounded rectangle with smooth
│                                S-curve protrusion on the left edge (centered vertically), fused into the
│                                window border via cubic bezier curves. This is the only part on-screen while
│                                collapsed, so it must look unchanged from the original "tab" design.
│                              - isExpanded == true: flushPath — plain rounded rect (16px corners), no bump,
│                                so the left column reads as flush/inside the window instead of poking out.
│                              Uses PanelController constants for dimensions.
│
└── SidePanel.swift            LEFT SIDEBAR. Houses the collapse/expand toggle, vertically centered via
                               Spacer/Spacer (so it also lands in the vertical center once the panel is
                               full height). Reserved for future sidebar functions — today it only has the
                               toggle button.
                               Chevron icon: compact left/right depending on isExpanded.
                               Hover: scale 1.08, opacity 1.0. Idle: opacity 0.75.
                               Context menu: "Quit SwiftApp-MacOS-Base-Model" (terminates app).
                               Frame width: PanelController.tabWidth (24px), unchanged between states —
                               only the PanelShape behind it (bump vs flush) changes with isExpanded.
```

---

## Key Architecture Decisions

| Decision | Reason |
|---|---|
| `@Observable` instead of `ObservableObject` | `ObservableObject` uses `@Published` which works, but `@Observable` is the modern pattern and ObservationMacros plugin IS available in Command Line Tools |
| No `@State`, `@Binding`, `@Environment` | SwiftUIMacros plugin is missing from Command Line Tools (only available with full Xcode). All local state lives in `@Observable` classes. Bindings use `Binding(get:set:)` |
| `NSPanel` instead of `WindowGroup` | Need borderless, non-activating, always-on-top floating window. SwiftUI WindowGroup doesn't support these requirements |
| `NSHostingView` bridge | Hosts SwiftUI views inside the AppKit NSPanel. SwiftUI handles all UI rendering |
| `.accessory` activation policy | No Dock icon, no menu bar — app behaves as a system-level utility |
| `swift-tools-version:6.2` | Required for `.macOS(.v26)` platform target |
| `.swiftLanguageMode(.v5)` | Avoids Swift 6 strict concurrency requirements while using 6.2 toolchain |
| `fswatch` for hot reload | Lightweight file watcher (Homebrew). Monitors Sources/ and triggers rebuild+relaunch |
| Sparkle for auto-update | De facto standard for non-App-Store macOS apps. Handles update checks, EdDSA-verified downloads, and silent install (SUAutomaticallyUpdate) |
| GitHub Releases "latest" redirect as feed URL | `releases/latest/download/appcast.xml` never changes, so Info.plist's SUFeedURL is static even though old releases get deleted on every tag push |
| Ad-hoc codesign only (no Developer ID yet) | No Apple Developer account configured. First launch after install/update shows a Gatekeeper warning until a Developer ID + notarization is added |

---

## Build & Run

```bash
swift build                    # compile
.build/debug/SwiftApp-MacOS-Base-Model          # run directly
bash dev.sh                    # hot reload (watch + rebuild + relaunch)

# Release packaging (normally done by .github/workflows/release.yml on a tag push):
swift build -c release
APP_VERSION=1.0.0 APP_OWNER=<owner> APP_REPO=<repo> SPARKLE_PUBLIC_KEY=<key> bash Scripts/package_app.sh
SPARKLE_PRIVATE_KEY=<key> bash Scripts/build_appcast.sh   # signs dist/*.zip, writes dist/appcast.xml

# One-time, local only (writes to your login Keychain, never run in CI):
bash Scripts/generate_sparkle_keys.sh
```

## Conventions

- **One responsibility per file** — each file contains a single struct/class/enum
- **Screen directories** — each screen gets its own directory under Screens/ with a Components/ subdirectory for local components
- **Shared components** — reusable across screens go in Components/
- **Models** — observable state and data types go in Models/
- **No comments in code** — code is self-documenting; this map file is the reference
