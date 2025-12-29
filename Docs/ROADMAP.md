# HomeInventory Roadmap

## Phase 1: Foundation (✅ Done)
- [x] **Project Setup:** SwiftUI + MVVM structure.
- [x] **Domain Modeling:** Defined `Location` (recursive) and `Item`.
- [x] **Persistence:** Built `DiskInventoryRepository` (JSON).
- [x] **Navigation:** Built `LocationTreeView` (recursive folders).
- [x] **Visuals:** Built `LocationDetailView` and `ImageStore`.
- [x] **Photo Integration:** Users can add photos to Rooms.

## Phase 2: The "Visual Map" (✅ Done)
- [x] **Hotspot Domain:** Define `Hotspot` struct (x, y, targetId).
- [x] **Repository Update:** Update `InventoryBackup` to save Hotspots.
- [x] **Admin Mode:** Toggle in UI to enable "Tap to Add Hotspot."
- [x] **Coordinate Capture:** Tap gesture to save (x, y) relative to image size.
- [x] **Navigation Linking:** Tap a hotspot -> Navigate to the target Location.

## Phase 3: Polish & Search (🚧 Next Up)
- [ ] **Search Bar:** Global search for Items (find "Passport" -> shows "Drawer A").
- [ ] **Breadcrumbs:** Show path `Kitchen > Cabinet > Shelf` in Detail View.
- [ ] **Item Management:** Edit/Delete items (Swipe actions).
- [ ] **Location Management:** Edit/Delete/Move locations.

## Phase 4: Advanced Features (Future)
- [ ] **QR Codes:** Generate QR codes for boxes to deep-link to content.
- [ ] **Export:** Export Inventory as CSV/PDF.
- [ ] **Cloud Sync:** (Maybe?) Google Drive / iCloud Backup of the JSON file.