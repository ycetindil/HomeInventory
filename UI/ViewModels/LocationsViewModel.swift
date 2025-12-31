import Foundation
import SwiftUI
import Observation

enum MoveError: LocalizedError {
    case circularDependency(String)
    
    var errorDescription: String? {
        switch self {
        case .circularDependency(let message):
            return message
        }
    }
}

@Observable
final class LocationsViewModel {
    private let repo: DiskInventoryRepository
    private let imageStore = ImageStore() // <--- NEW: The Image Manager

    var locations: [Location] = []
    var hotspots: [Hotspot] = []
    var searchText: String = ""

    init(repo: DiskInventoryRepository = DiskInventoryRepository()) {
        self.repo = repo
        self.locations = repo.locations
        self.hotspots = repo.hotspots
        sanitizeData()
    }
    
    // MARK: - Data Sanitization
    
    private func sanitizeData() {
        let locationIds = Set(locations.map(\.id))
        var dataRemoved = false
        
        // Remove hotspots pointing to non-existent locations
        let initialHotspotCount = hotspots.count
        hotspots.removeAll { !locationIds.contains($0.targetLocationId) }
        if hotspots.count < initialHotspotCount {
            dataRemoved = true
            print("🧹 Removed \(initialHotspotCount - hotspots.count) orphaned hotspot(s)")
        }
        
        // Remove items in non-existent locations
        let initialItemCount = repo.items.count
        repo.items.removeAll { item in
            if let locationId = item.locationId {
                return !locationIds.contains(locationId)
            }
            return false // Keep items with nil locationId (they're at root level)
        }
        if repo.items.count < initialItemCount {
            dataRemoved = true
            print("🧹 Removed \(initialItemCount - repo.items.count) orphaned item(s)")
        }
        
        // Save if any data was removed
        if dataRemoved {
            save()
        }
    }
    
    var searchResults: [Item] {
        guard !searchText.isEmpty else { return [] }
        let query = searchText.lowercased()
        return repo.items.filter { item in
            item.name.lowercased().contains(query)
        }
    }
    
    func location(for item: Item) -> Location? {
        guard let locationId = item.locationId else { return nil }
        return location(id: locationId)
    }

    // MARK: - Image Handling (NEW)
    
    @MainActor
    func setImage(_ image: UIImage, for locationId: UUID) {
        let imageId = UUID()
        
        Task {
            // 1. Perform I/O (Background)
            try? await imageStore.save(image, id: imageId)
            
            // 2. Jump back to Main Thread for State Updates
            await MainActor.run {
                print("📸 Image saved. Updating ViewModel now...") // Debug Log
                // Re-fetch location to ensure thread safety
                if var updatedLocation = self.location(id: locationId) {
                    updatedLocation.primaryMapImageId = imageId
                    // Update Repo
                    repo.updateLocation(updatedLocation)
                    // Update UI Source of Truth
                    if let index = self.locations.firstIndex(where: { $0.id == locationId }) {
                        self.locations[index] = updatedLocation
                        print("✅ ViewModel locations updated. New ID: \(imageId)") // Debug Log
                        print("🧠 VM Instance (Source): \(Unmanaged.passUnretained(self).toOpaque())") // <--- ADD THIS // Debug Log
                    }
                }
            }
        }
    }
    
    func image(for location: Location) async -> UIImage? {
        guard let imageId = location.primaryMapImageId else { return nil }
        // Load image asynchronously from actor - no blocking!
        return await imageStore.load(id: imageId)
    }

    // MARK: - Existing Logic
    
    func addLocation(name: String, type: LocationType, parentId: UUID? = nil) {
        repo.addLocation(name: name, type: type, parentId: parentId)
        // Sync local array with repository
        locations = repo.locations
    }
    
    func updateLocation(_ location: Location, newName: String, type: LocationType) {
        var updatedLocation = location
        updatedLocation.name = newName
        updatedLocation.type = type
        updatedLocation.updatedAt = Date()
        repo.updateLocation(updatedLocation)
        // Sync local array with repository
        locations = repo.locations
    }
    
    func deleteLocation(_ id: UUID) {
        // Cascading delete: recursively delete all descendants
        deleteLocationRecursive(id)
        // Sync local array with repository
        locations = repo.locations
    }
    
    private func deleteLocationRecursive(_ locationId: UUID) {
        // Find all direct children from the repository (source of truth)
        let children = repo.locations.filter { $0.parentId == locationId }
        
        // Recursively delete each child (which will delete their descendants)
        for child in children {
            deleteLocationRecursive(child.id)
        }
        
        // Delete all items in this location
        let itemsToDelete = repo.items.filter { $0.locationId == locationId }
        for item in itemsToDelete {
            repo.deleteItem(item.id)
        }
        
        // Delete hotspots associated with this location's image or pointing to this location
        if let location = repo.locations.first(where: { $0.id == locationId }) {
            if let imageId = location.primaryMapImageId {
                hotspots.removeAll { $0.mapImageId == imageId || $0.targetLocationId == locationId }
                save()
            } else {
                // Even without image, remove hotspots pointing to this location
                hotspots.removeAll { $0.targetLocationId == locationId }
                save()
            }
        }
        
        // Finally, delete the location itself
        repo.deleteLocation(locationId)
    }

    var roots: [Location] {
        locations.filter { $0.parentId == nil }.sorted(by: Self.locationSort)
    }

    func children(of parentId: UUID) -> [Location] {
        locations.filter { $0.parentId == parentId }.sorted(by: Self.locationSort)
    }
    
    func childCount(of parentId: UUID) -> Int {
        locations.filter { $0.parentId == parentId }.count
    }

    func location(id: UUID) -> Location? {
        locations.first(where: { $0.id == id })
    }
    
    func location(with id: UUID) -> Location? {
        return locations.first { $0.id == id }
    }
    
    func breadcrumbPath(for location: Location) -> [Location] {
        var path: [Location] = []
        var current: Location? = location
        
        // Build path from current location up to root
        while let loc = current {
            path.append(loc)
            if let parentId = loc.parentId {
                current = self.location(id: parentId)
            } else {
                current = nil
            }
        }
        
        // Reverse to get root -> current path
        return path.reversed()
    }
    
    func items(for locationId: UUID) -> [Item] {
        repo.items.filter { $0.locationId == locationId }
    }
    
    func item(id: UUID) -> Item? {
        repo.items.first(where: { $0.id == id })
    }
    
    func addItem(name: String, parentId: UUID?) {
        repo.addItem(name: name, locationId: parentId)
    }
    
    func deleteItem(_ id: UUID) {
        repo.deleteItem(id)
    }
    
    func updateItem(_ item: Item, name: String, quantity: Int, note: String?) {
        var updatedItem = item
        updatedItem.name = name
        updatedItem.quantity = quantity
        updatedItem.note = note
        updatedItem.updatedAt = Date()
        repo.updateItem(updatedItem)
    }
    
    func duplicateItem(_ item: Item, to targetLocationId: UUID?) {
        let newItem = Item(
            id: UUID(),
            locationId: targetLocationId,
            name: item.name + " Copy",
            note: item.note,
            quantity: item.quantity,
            createdAt: Date(),
            updatedAt: Date()
        )
        repo.items.append(newItem)
        repo.save(hotspots: hotspots)
    }
    
    func moveItem(_ item: Item, to destinationLocationId: UUID?) {
        var updatedItem = item
        updatedItem.locationId = destinationLocationId
        updatedItem.updatedAt = Date()
        repo.updateItem(updatedItem)
    }
    
    func moveLocation(_ location: Location, to destinationParentId: UUID?) throws {
        // Prevent circular dependency: cannot move location into itself or its descendants
        if let destinationId = destinationParentId {
            if destinationId == location.id {
                throw MoveError.circularDependency("Cannot move a location into itself")
            }
            
            // Check if destination is a descendant of the location being moved
            // (i.e., we can't move a parent into its child)
            let descendants = allDescendantIds(of: location.id)
            if descendants.contains(destinationId) {
                throw MoveError.circularDependency("Cannot move a location into its own descendant")
            }
        }
        
        var updatedLocation = location
        updatedLocation.parentId = destinationParentId
        updatedLocation.updatedAt = Date()
        repo.updateLocation(updatedLocation)
        // Sync local array with repository
        locations = repo.locations
    }
    
    func allDescendantIds(of locationId: UUID) -> Set<UUID> {
        var descendants: Set<UUID> = []
        var toProcess = [locationId]
        
        while !toProcess.isEmpty {
            let currentId = toProcess.removeFirst()
            let children = repo.locations.filter { $0.parentId == currentId }
            for child in children {
                descendants.insert(child.id)
                toProcess.append(child.id)
            }
        }
        
        return descendants
    }
    
    // MARK: - Hotspot Actions
    
    func addHotspot(locationId: UUID, x: Double, y: Double, mapImageId: UUID) {
        let newHotspot = Hotspot(
            mapImageId: mapImageId,
            targetLocationId: locationId,
            x: x,
            y: y
        )
        hotspots.append(newHotspot)
        save()
    }

    func save() {
        repo.save(hotspots: hotspots)
    }

    private nonisolated static func locationSort(_ a: Location, _ b: Location) -> Bool {
        if a.sortOrder != b.sortOrder { return a.sortOrder < b.sortOrder }
        return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
    }
}
