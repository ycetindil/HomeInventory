import Foundation
import Observation

@Observable
final class LocationsViewModel {
    private let repo: DiskInventoryRepository

    var locations: [Location] { repo.locations }

    // FIXED: Added '= DiskInventoryRepository()' to handle missing arguments
    init(repo: DiskInventoryRepository = DiskInventoryRepository()) {
        self.repo = repo
    }

    func addLocation(name: String, type: LocationType, parentId: UUID? = nil) {
        repo.addLocation(name: name, type: type, parentId: parentId)
    }

    // MARK: - Tree helpers

    var roots: [Location] {
        locations
            .filter { $0.parentId == nil }
            .sorted(by: Self.locationSort)
    }

    func children(of parentId: UUID) -> [Location] {
        locations
            .filter { $0.parentId == parentId }
            .sorted(by: Self.locationSort)
    }
    
    func childCount(of parentId: UUID) -> Int {
        locations.filter { $0.parentId == parentId }.count
    }

    func location(id: UUID) -> Location? {
        locations.first(where: { $0.id == id })
    }

    private nonisolated static func locationSort(_ a: Location, _ b: Location) -> Bool {
        if a.sortOrder != b.sortOrder { return a.sortOrder < b.sortOrder }
        return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
    }
    
    // NEW: Get items that belong to a specific location
    func items(for locationId: UUID) -> [Item] {
        repo.items.filter { $0.locationId == locationId }
    }
    
    // NEW: Add item helper
    func addItem(name: String, parentId: UUID?) {
        repo.addItem(name: name, locationId: parentId)
    }
}
