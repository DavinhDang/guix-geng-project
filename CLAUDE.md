# guix-geng-project — Claude Code Context

## Project Overview

This is a Guix channel repository for packaging 3D Slicer medical imaging software and related extensions. The repo lives at `https://github.com/DavinhDang/guix-geng-project` and is used on a Linux Mint system (MacBook Air).

## Repository Structure

```
guix-geng-project/
├── .guix-channel                          # Channel config with systole dependency
├── guix-geng-project/packages/
│   ├── myext.scm                          # ✅ WORKING - Slicer extension package
│   ├── slicer-custom-app-template.scm     # 🔧 IN PROGRESS - Custom app template
│   └── slicer-app-generator.scm           # Draft package
└── myext/                                 # Slicer extension source
    └── LoadableMVoxMeshGen/               # The actual C++ loadable module
```

## channels.scm

```scheme
(list (channel
       (name 'guix)
       (url "https://git.guix.gnu.org/guix.git")
       (commit "ba516ec"))
      (channel
       (name 'systole)
       (url "https://github.com/SystoleOS/guix-systole.git")
       (branch "main")
       (commit "3b42810"))
      (channel
       (name 'mvox)
       (url "https://github.com/benzwick/guix-mvox.git")
       (branch "main"))
      (channel
       (name 'guix-geng-project)
       (url "https://github.com/DavinhDang/guix-geng-project.git")
       (branch "main")))
```

## .guix-channel

```scheme
(channel
  (version 0)
  (dependencies
   (channel
    (name systole)
    (url "https://github.com/SystoleOS/guix-systole.git")
    (branch "main"))))
```

Key: channel name in `.guix-channel` uses plain symbol (no quote), unlike `channels.scm`.

## Package Status

### myext ✅ WORKING

- Packages the `LoadableMVoxMeshGen` Slicer loadable module extension
- Source: fetches `guix-geng-project` repo and chdirs into `myext/`
- Installs to `lib/Slicer-5.8/qt-loadable-modules/`
- Load in Slicer: `Slicer --additional-module-paths <store-path>/lib/Slicer-5.8/qt-loadable-modules`

Key fixes applied:
- `patch-cpack`: patches out `include(${Slicer_EXTENSION_CPACK})` — CPack requires build-time vars not in installed Slicer
- `add-slicer-base-logic`: appends `target_link_libraries` to `Logic/CMakeLists.txt` to link `libSlicerBaseLogic.so` — provides `vtkSlicerModuleLogic` base class, missing from default link
- `add-qmrml-widgets`: appends `target_link_libraries PUBLIC` to module `CMakeLists.txt` to link `libqMRMLWidgets.so` — provides `qMRMLNodeComboBox`
- RPATH fix: `-DCMAKE_INSTALL_RPATH=#$output/lib/Slicer-5.8/qt-loadable-modules` so `.so` files find each other at runtime
- `#:validate-runpath? #f` required since Slicer modules cross-reference across directories

### slicer-custom-app-template 🔧 IN PROGRESS

- Source: `https://github.com/DavinhDang/SlicerCustomAppTemplate`
- Core challenge: `CMakeLists.txt` uses `add_subdirectory(${slicersources_SOURCE_DIR})` — builds Slicer from source
- Currently only installs LICENSE file — CMake generates no build targets
- FetchContent network calls patched out (Guix sandbox has no network):
  - `slicersources` (Slicer source) — pre-fetched as origin, extracted to `slicersources-src/`
  - `SlicerCustomAppUtilities` — pre-fetched as origin, extracted to `SlicerCustomAppUtilities/`
- `slicersources_SOURCE_DIR` and `slicersources_BINARY_DIR` injected via `substitute*` in `CMakeLists.txt`
- Next step: replicate systole's `%slicer-5.8` build approach — use Slicer source tarball + full dependency list + `Slicer_SUPERBUILD=OFF` + all `Slicer_USE_SYSTEM_*` flags

## Key Technical Facts

### Guix/Scheme

- Module names must match file paths exactly: `(guix-geng-project packages myext)` → `guix-geng-project/packages/myext.scm`
- systole channel modules use namespace `(systole packages slicer)` not `(guix-systole packages slicer)`
- Qt5 Guile variables use `-5` suffix: `qtbase-5`, `qtmultimedia-5` etc.
- `assoc-ref inputs "qtbase"` uses package name (no `-5`), variable name uses `-5`
- `this-package-input "qtbase"` also uses package name (no `-5`)
- `substitute*` does NOT match across newlines by default — use append to file instead
- `read-line` and `read-string` unavailable in build gexps without imports — use `get-line` or append approach
- `#:out-of-source? #t` means build dir is separate from source; phases run from build dir; source is at `../source/`

### Slicer/CMake

- `libSlicerBaseLogic.so` is at `lib/Slicer-5.8/libSlicerBaseLogic.so`
- `libqMRMLWidgets.so` is at `lib/Slicer-5.8/libqMRMLWidgets.so`
- `SlicerMacroBuildLoadableModule` uses keyword (`PUBLIC`) signature for `target_link_libraries`
- `SlicerMacroBuildModuleLogic` uses plain signature
- `Slicer_EXTENSION_GENERATE_CONFIG` and `Slicer_EXTENSION_CPACK` are NOT exported in installed `SlicerConfig.cmake` — must be set manually or patched out
- `slicersources_SOURCE_DIR` controls whether Slicer source is fetched — if defined, FetchContent is skipped
- `add_subdirectory(${slicersources_SOURCE_DIR})` means the template builds Slicer from source, not against installed Slicer

### systole channel

- Repo: `https://github.com/SystoleOS/guix-systole.git`
- Module path: `systole/systole/packages/slicer.scm` (double `systole/` due to `.guix-channel` directory setting)
- Base package: `%slicer-5.8` defined around line 112 of `slicer.scm`
- Public package: `slicer-5.8` inherits from `%slicer-5.8` with Python added
- Slicer 5.8.1 commit: `11eaf62e5a70b828021ff8beebbdd14d10d4f51c`
- Slicer 5.8.1 hash: `05rz797ddci3a2m8297zyzv2g2hp6bd6djmwa1n0gbsla8b175bx`
- Pinned to commit `3b42810` due to upstream `slicer.scm` syntax error in later commits

## Current Work Item

Implementing `slicer-custom-app-template` as a full build (like systole's `slicer-5.8`) by:
1. Reading `%slicer-5.8` inputs from systole `slicer.scm` (around line 112-695)
2. Reusing those same inputs + configure flags in `slicer-custom-app-template.scm`
3. Using `SlicerCustomAppTemplate` CMakeLists.txt as the project root
4. Pointing `slicersources_SOURCE_DIR` to Slicer 5.8.1 source tarball

Slicer source for template (from CMakeLists.txt line 17):
- Commit: `0e1b0d5bd12e7fd274ded9799f264d01b6014f1f`
- Hash: `0ln39yrjp4qr2x8w265359xd8kkav3b6zc5npvidf4z8qi80q4ia`

SlicerCustomAppUtilities (from CMakeLists.txt line 154):
- Commit: `1d984a2c9143e2617ff1ffa9d86c51e07dc6321e`
- Hash: `1qyzfsdz64pkd87iixjkiqasxxqsdiwpxpca7nsnszs6yr3aswkb`
