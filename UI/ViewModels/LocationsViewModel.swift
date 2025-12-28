import Foundation
import SwiftUI
import Observation

@Observable
final class LocationsViewModel {
    private let repo: DiskInventoryRepository
    private let imageStore = ImageStore() // <--- NEW: The Image Manager

    var locations: [Location] { repo.locations }

    init(repo: DiskInventoryRepository = DiskInventoryRepository()) {
        self.repo = repo
    }

    // MARK: - Image Handling (NEW)
    
    @MainActor
    func setImage(_ image: UIImage, for locationId: UUID) {
        // 1. Generate a new ID for the image
        let imageId = UUID()
        
        // 2. Save the file to disk
        Task {
            try? await imageStore.save(image, id: imageId)
        }
        
        // 3. Update the Location record to point to this new image
        if var loc = location(id: locationId) {
            // Delete old image if it existed? (Optional cleanup)
            loc.primaryMapImageId = imageId
            repo.updateLocation(loc)
        }
    }
    
    @MainActor
    func image(for location: Location) -> UIImage? {
        guard let imageId = location.primaryMapImageId else { return nil }
        // Note: loading synchronously on main thread for simplicity in MVP.
        // In a huge app, we'd make this async.
        var loadedImage: UIImage?
        let sema = DispatchSemaphore(value: 0)
        
        Task {
            loadedImage = await imageStore.load(id: imageId)
            sema.signal()
        }
        sema.wait()
        return loadedImage
    }

    // MARK: - Existing Logic
    
    func addLocation(name: String, type: LocationType, parentId: UUID? = nil) {
        repo.addLocation(name: name, type: type, parentId: parentId)
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
    
    func items(for locationId: UUID) -> [Item] {
        repo.items.filter { $0.locationId == locationId }
    }
    
    func addItem(name: String, parentId: UUID?) {
        repo.addItem(name: name, locationId: parentId)
    }

    private nonisolated static func locationSort(_ a: Location, _ b: Location) -> Bool {
        if a.sortOrder != b.sortOrder { return a.sortOrder < b.sortOrder }
        return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
    }
}
