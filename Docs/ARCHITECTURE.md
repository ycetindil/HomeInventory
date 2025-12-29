# Home Inventory App — Architecture

> **Purpose:** iPhone-first, visual-first home inventory.
> **Core Loop:** Room Photo -> Tap Hotspot -> See Items.
> **Philosophy:** "No Storage" is a feature. Local-first JSON allows easy backup/export.

---

## 1. UX Strategy
1.  **The "Quick Add" Rule:** Avoid "tax form" data entry. Allow creating an Item + Type in one go.
2.  **Visual Map:**
    - MVP: Tappable "Dots" (Hotspots) on a Room Photo.
    - Hotspots use normalized coordinates (0.0 to 1.0) so they work on any screen size.
3.  **File Management:**
    - Photos/PDFs live in App Sandbox (Documents/Images).
    - Database (`inventory.json`) only stores the filename/UUID reference.

---

## 2. Layers & Boundaries
**1. Domain Layer (`DomainModels.swift`)**
- Pure Swift Structs.
- **Stable IDs:** Every entity has `id: UUID`.
- **No Dependencies:** No SwiftUI, no File I/O imports.

**2. Data Layer (`DiskInventoryRepository.swift`)**
- **Single Source of Truth:** One JSON file (`inventory.json`) loaded into memory.
- **Auto-Migration:** Fallback logic in `init()` to handle schema changes (e.g., adding Hotspots).
- **ImageStore:** Actor-isolated class handling writing/reading UIImages to disk.

**3. UI Layer (SwiftUI)**
- **MVVM:** `LocationsViewModel` holds the `repo` and exposes data.
- **No Logic in Views:** Views only present data and call VM functions.

---

## 3. Data Models (Reference)

### Core Entities (Implemented)
* **Location:** `id`, `parentId?`, `name`, `type`, `primaryMapImageId?`
* **Item:** `id`, `locationId?`, `name`, `quantity`, `note`

### Visuals (In Progress)
* **Hotspot:** `id`, `mapImageId`, `targetLocationId`, `x`, `y` (0-1), `label`

### Future Entities (Not Implemented Yet)
* **ItemType:** Abstract definition (e.g., "Sony Bravia TV") vs Instance (the physical one).
* **MaterialSystem:** Paint, Flooring, HVAC systems (coverage-based).
* **Relationship:** Graph connections (e.g., "Remote Control" *controls* "TV").
* **Attachment:** PDFs, Receipts linked to Items.

---

## 4. Feature Roadmap (Technical)
**Phase 1: Foundation (✅ Done)**
- JSON Persistence.
- Recursive Tree Navigation.
- Image Saving (ImageStore).

**Phase 2: Visual Navigation (🚧 Current)**
- [ ] Add `Hotspot` struct to `DomainModels`.
- [ ] Update Repository to save `[Hotspot]`.
- [ ] UI: "Edit Mode" overlay on Room Photo to tap-and-add dots.
- [ ] Interaction: Tapping a dot navigates to that Location.

**Phase 3: Refinement**
- [ ] Search Bar.
- [ ] Swipe-to-delete Items.
- [ ] Move Item (Change `locationId`).

**Phase 4: Advanced**
- [ ] Export to ZIP (JSON + Images).
- [ ] QR Code generation.