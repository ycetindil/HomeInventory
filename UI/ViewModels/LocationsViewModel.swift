import Foundation
import Observation

@Observable
final class LocationsViewModel {
    private let repo: InMemoryInventoryRepository

    // Flat list (still useful)
    var locations: [Location] { repo.locations }

    init(repo: InMemoryInventoryRepository = InMemoryInventoryRepository()) {
        self.repo = repo
    }

    func addLocation(name: String, type: LocationType, parentId: UUID? = nil) {
        repo.addLocation(name: name, type: type, parentId: parentId)
    }

    // MARK: - Tree helpers

    /// Top-level locations (no parent), sorted by sortOrder then name
    var roots: [Location] {
        locations
            .filter { $0.parentId == nil }
            .sorted(by: Self.locationSort)
    }

    /// Direct children of a location, sorted by sortOrder then name
    func children(of parentId: UUID) -> [Location] {
        locations
            .filter { $0.parentId == parentId }
            .sorted(by: Self.locationSort)
    }
    
    func childCount(of parentId: UUID) -> Int {
        repo.locations.filter { $0.deletedAt == nil && $0.parentId == parentId }.count
    }

    /// Optional convenience if you want lookups
    func location(id: UUID) -> Location? {
        locations.first(where: { $0.id == id })
    }

    private static func locationSort(_ a: Location, _ b: Location) -> Bool {
        if a.sortOrder != b.sortOrder { return a.sortOrder < b.sortOrder }
        return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
    }
}
