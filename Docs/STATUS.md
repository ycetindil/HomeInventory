# HomeInventory – Current State

## App wiring
- Entry: `HomeInventoryApp.swift` -> `ContentView()`
- `ContentView` owns the screen-level state via `LocationsViewModel`
- UI:
  - `ContentView` -> `LocationTreeView(vm: LocationsViewModel)` (current)
  - `AddLocationSheet` (in progress/next)

## Domain
- `DomainModels.swift`
  - `Location` (UUID id, parentId tree, type, sortOrder, primaryMapImageId, timestamps + soft delete)
  - `LocationType` enum

## Data
- Repository: `InMemoryInventoryRepository(seed: true)`
- Seed locations: **5**
  1) Home (house)
  2) Kitchen (room) -> child: Cabinet A
  3) Garage (room)
  4) Cabinet A (cabinet) -> child: Drawer 1
  5) Drawer 1 (drawer)

## ViewModel
- `LocationsViewModel` uses `@Observable` (Observation)
  - Exposes:
    - `locations` (computed from repo)
    - `addLocation(...)`
    - `childCount(of:)` (for the UI indicator)

## UI behavior
- Tree navigation: tap a location drills into its children (filtered by `parentId`)
- Each row shows a right-side **count capsule** when it has children

## Rules / guardrails we’re enforcing
- `HomeInventoryApp.swift` must not contain static test UI/data (except compile-check).
- Seed/test data lives in repository or previews.
- SwiftUI views only consume **domain structs** (no persistence types).

## Next step
- Add basic “+ Add Location” UI (start with adding a child under the current node).
