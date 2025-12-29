import Foundation
import SwiftUI
import Observation

@Observable
final class LocationsViewModel {
    private let repo: DiskInventoryRepository
    private let imageStore = ImageStore() // <--- NEW: The Image Manager

    var locations: [Location] = []
    var hotspots: [Hotspot] = []

    init(repo: DiskInventoryRepository = DiskInventoryRepository()) {
        self.repo = repo
        self.locations = repo.locations
        self.hotspots = repo.hotspots
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
    
    func items(for locationId: UUID) -> [Item] {
        repo.items.filter { $0.locationId == locationId }
    }
    
    func addItem(name: String, parentId: UUID?) {
        repo.addItem(name: name, locationId: parentId)
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
