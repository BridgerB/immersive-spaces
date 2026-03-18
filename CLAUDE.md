# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Apple Vision Pro (visionOS) application built with SwiftUI and RealityKit. It displays an immersive 3D environment with video playback capabilities, targeting visionOS 26.2.

## Build & Development

This is an Xcode project — there are no CLI build commands for typical development. Use Xcode to build and run on a Vision Pro device or simulator.

- **Open project:** `open immersive-spaces.xcodeproj`
- **Scheme:** `immersive-spaces`
- **Deployment target:** visionOS 26.2
- **3D content editing:** Open `Packages/RealityKitContent/` in Reality Composer Pro for editing `.usda` scenes and 3D assets

There are no tests in this project.

## Architecture

### Two-Scene SwiftUI App

The app uses two SwiftUI scenes simultaneously:
- **`WindowGroup`**: Standard 2D window — shows `AVPlayerView` when video is playing, otherwise `ContentView`
- **`ImmersiveSpace`**: Full immersive 3D rendering via RealityKit

### State Machine

`AppModel` holds the immersive space state: `.closed` → `.inTransition` → `.open` (and back). The critical design choice is that **`ImmersiveView` lifecycle hooks** (`onAppear`/`onDisappear`) own the state transitions to `.open`/`.closed`, while `ToggleImmersiveSpaceButton` only sets `.inTransition` and triggers the open/dismiss calls. This avoids race conditions.

### RealityKit Content Package

3D assets live in `Packages/RealityKitContent/` as a local Swift Package with no external dependencies. The main scene (`Immersive.usda`) contains:
- **SkyDome**: External USDZ asset scaled to 1%
- **Video_Dock**: Container at (0, 0.8, -3) with a `CustomDockingRegion` for video player bounds
- **Ground**: Referenced ground plane mesh

### Video Playback

`AVPlayerViewModel` wraps `AVPlayer` and bridges into SwiftUI via `AVPlayerView` (`UIViewControllerRepresentable`). The `videoURL` is currently `nil` (stub — needs implementation). Video playback starts when the immersive space opens and resets when it closes.

### Key Files

| File | Purpose |
|------|---------|
| `immersive_spacesApp.swift` | App entry, scene definitions, wires AppModel + AVPlayerViewModel |
| `AppModel.swift` | Global state, immersive space state machine |
| `ImmersiveView.swift` | RealityKit scene loading, owns `.open`/`.closed` state transitions |
| `ToggleImmersiveSpaceButton.swift` | Orchestrates space open/dismiss, sets `.inTransition` |
| `AVPlayerViewModel.swift` | Video playback logic (videoURL currently nil) |
| `Packages/RealityKitContent/Sources/.../Immersive.usda` | Main 3D scene definition |

### Concurrency

`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` is set globally. Both `AppModel` and `AVPlayerViewModel` are `@MainActor @Observable` classes.
