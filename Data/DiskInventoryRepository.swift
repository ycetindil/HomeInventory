import Foundation
import Observation

// 1. The container for everything we save to disk
struct InventoryBackup: Codable {
    let locations: [Location]
    let items: [Item]
}

@Observable
final class DiskInventoryRepository {
    // Two separate lists, but they live in the same file
    var locations: [Location] = []
    var items: [Item] = []
    
    private var fileURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("inventory.json")
    }
    
    init() {
        load()
    }
    
    // MARK: - Location Actions
    func addLocation(name: String, type: LocationType, parentId: UUID?) {
        let newLocation = Location(parentId: parentId, name: name, type: type)
        locations.append(newLocation)
        save()
    }
    
    func updateLocation(_ location: Location) {
        if let index = locations.firstIndex(where: { $0.id == location.id }) {
            locations[index] = location
            save()
        }
    }
    
    func deleteLocation(_ id: UUID) {
        locations.removeAll { $0.id == id }
        // Optional: Recursively delete items in this location?
        // For now, we'll leave them (orphaned items) or handle later.
        save()
    }
    
    // MARK: - Item Actions
    func addItem(name: String, locationId: UUID?) {
        let newItem = Item(locationId: locationId, name: name)
        items.append(newItem)
        save()
    }
    
    func deleteItem(_ id: UUID) {
        items.removeAll { $0.id == id }
        save()
    }
    
    // MARK: - Save/Load Logic
    private func save() {
        do {
            // Pack both lists into the backup struct
            let backup = InventoryBackup(locations: locations, items: items)
            let data = try JSONEncoder().encode(backup)
            try data.write(to: fileURL)
            print("💾 Saved \(locations.count) locs and \(items.count) items.")
        } catch {
            print("❌ Failed to save: \(error)")
        }
    }
    
    private func load() {
        // Read the raw data first so it's available in both success and fallback paths
        guard let data = try? Data(contentsOf: fileURL) else {
            print("⚠️ No saved inventory found (starting fresh).")
            self.locations = []
            self.items = []
            return
        }

        do {
            // Try to decode the new format (Locations + Items)
            let backup = try JSONDecoder().decode(InventoryBackup.self, from: data)
            self.locations = backup.locations
            self.items = backup.items
            print("📂 Loaded \(locations.count) locs and \(items.count) items.")
        } catch {
            // Fallback: Try to decode the OLD format (Just [Location]) so we don't crash
            if let oldLocations = try? JSONDecoder().decode([Location].self, from: data) {
                print("♻️ Migrating old data format...")
                self.locations = oldLocations
                self.items = []
                save() // Upgrade file format immediately
            } else {
                print("⚠️ Failed to decode saved inventory: \(error)")
                self.locations = []
                self.items = []
            }
        }
    }
}
