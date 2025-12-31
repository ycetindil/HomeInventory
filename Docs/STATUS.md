# HomeInventory – STATUS

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
    - `searchResults`: Real-time filtered list of items based on search query.
    - `breadcrumbPath(for:)`: Computes navigation path to root.
    - `moveItem`/`moveLocation`: Handles reparenting with circular dependency checks.
    - `deleteLocationRecursive`: Cascading delete for folders and contents.

## UI / Features
- **Unified Navigation:** `LocationView.swift`
  - **Search:** Global item search via `searchable`.
  - **Breadcrumbs:** Navigation path header (`BreadcrumbView`) for easy traversal.
  - **Visual Header:** Interactive Room Photo with Hotspots.
- **Item Management:**
  - **Edit:** "Tap to Edit" pattern (opens `ItemDetailView` in edit mode).
  - **Actions:** Swipe/Context Menu to **Move**, **Duplicate**, or **Delete** (with confirmation).
- **Location Management:**
  - **Drill Down:** Tapping a location navigates inside.
  - **Settings:** "Edit" button opens settings to Rename, Move (Picker), or Delete.
- **Add Flows:**
  - `AddLocationSheet`: Creates new containers.
  - `Hotspot Alert`: Visual creation of locations.

## Architecture Guardrails
1.  **No Core Data/SwiftData in Views:** UI consumes only pure Swift structs.
2.  **Stable IDs:** Everything uses UUIDs.
3.  **Local First:** All data lives in the App Sandbox (JSON + Images).

## Immediate Next Steps
- **Export:** Export Inventory as CSV/JSON (Phase 4).
- **Settings:** App-level settings page.