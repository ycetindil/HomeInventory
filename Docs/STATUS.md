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
- `ImageStore` (Actor) - Handles saving/loading images to the "Images" folder in App Sandbox.

## Data Layer
- **Repository:** `DiskInventoryRepository.swift`
  - Stores data in `inventory.json`.
  - Saves a single `InventoryBackup` struct containing both `[Location]` and `[Item]`.
  - Handles migration from old formats automatically (fallback logic).
- **Image Storage:** `ImageStore.swift`
  - Saves high-res photos to disk using UUID filenames.

## ViewModel
- `LocationsViewModel.swift` (`@Observable`)
  - Exposes `locations` and `items` to the UI.
  - **Logic:**
    - `roots`: Top-level locations (e.g., House).
    - `children(of:)`: Sub-locations (e.g., Kitchen).
    - `items(for:)`: Items inside a specific location.
    - `setImage(...)` / `image(for:)`: Bridges Domain to ImageStore.

## UI / Features
- **Tree Navigation:** `LocationTreeView`
  - Acts like a file browser.
  - Shows **Folders** (Sub-locations) and **Files** (Items) in one list.
  - "Add Location" and "Add Item" buttons are context-aware.
- **Detail View:** `LocationDetailView`
  - **Visual Header:** Displays the Room Photo (or placeholder).
  - **Photo Picker:** Native iOS picker to add/change room photos.
  - **Items List:** Quick list of items in that room.
- **Add Flows:**
  - `AddLocationSheet`: Creates new containers.
  - `Alerts`: Quick-add items via text prompt.

## Architecture Guardrails
1.  **No Core Data/SwiftData in Views:** UI consumes only pure Swift structs.
2.  **Stable IDs:** Everything uses UUIDs.
3.  **Local First:** All data lives in the App Sandbox (JSON + Images).

## Immediate Next Steps
- **Visual Hotspots (Admin Mode):**
  - Add tap gesture to `LocationDetailView` image.
  - Store (x,y) coordinates relative to the image (0.0 to 1.0).
