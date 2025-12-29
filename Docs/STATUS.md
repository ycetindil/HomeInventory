# HomeInventory – Current State

> **Repository:** `ycetindil/HomeInventory`
> **Architecture:** Local-First, MVVM, Domain-Driven Design

---

## App wiring
- Entry: `HomeInventoryApp.swift` -> `ContentView()`
- **Persistence Strategy:** JSON-based Disk Storage (Documents Directory).
- **Dependency Injection:** `DiskInventoryRepository` is created in App and injected into `LocationsViewModel`.

## Domain Models
- `Location` (UUID, parentId, type, sortOrder, primaryMapImageId)
- `LocationType` (House, Room, Cabinet, Drawer, etc.)
- `Item` (UUID, locationId, name, quantity, notes)
- `Hotspot` (UUID, mapImageId, targetLocationId, x, y, label)
- `ImageStore` (Actor) - Handles saving/loading images to the "Images" folder in App Sandbox.

## Data Layer
- **Repository:** `DiskInventoryRepository.swift`
  - Stores data in `inventory.json`.
  - Saves a single `InventoryBackup` struct containing `[Location]`, `[Item]`, and `[Hotspot]`.
  - Handles migration from old formats automatically (fallback logic).
- **Image Storage:** `ImageStore.swift`
  - Saves high-res photos to disk using UUID filenames.

## ViewModel
- `LocationsViewModel.swift` (`@Observable`)
  - Exposes `locations`, `items`, and `hotspots` to the UI.
  - **Logic:**
    - `roots`: Top-level locations (e.g., House).
    - `children(of:)`: Sub-locations (e.g., Kitchen).
    - `items(for:)`: Items inside a specific location.
    - `setImage(...)` / `image(for:)`: Bridges Domain to ImageStore with MainActor safety.
    - `addHotspot(...)`: Creates visual links between photos and locations.

## UI / Features
- **Unified Navigation:** `LocationView.swift` (Formerly LocationTreeView)
  - Acts as the single source of truth for navigation.
  - **Visual Header:** Displays Room Photo with interactive Hotspots.
  - **Admin Mode:** "Edit Map" button allows tapping photo to create new sub-locations.
  - **Recursive Tree:** Handles deep navigation through folders (Sub-locations) and Files (Items).
- **Add Flows:**
  - `AddLocationSheet`: Creates new containers.
  - `Alerts`: Quick-add items via text prompt.
  - `Hotspot Alert`: Captures (x,y) and names a new location in one step.

## Architecture Guardrails
1.  **No Core Data/SwiftData in Views:** UI consumes only pure Swift structs.
2.  **Stable IDs:** Everything uses UUIDs.
3.  **Local First:** All data lives in the App Sandbox (JSON + Images).

## Immediate Next Steps
- **Search:** Implement global item search.
- **Polish:** Add breadcrumbs and swipe actions.