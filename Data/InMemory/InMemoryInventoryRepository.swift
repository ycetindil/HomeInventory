import Foundation
import Observation

@Observable
final class InMemoryInventoryRepository {
    private(set) var locations: [Location] = []

    init(seed: Bool = true) {
        if seed { self.locations = Self.seedLocations() }
    }

    func addLocation(name: String, type: LocationType, parentId: UUID? = nil) {
        let new = Location(parentId: parentId, name: name, type: type, sortOrder: locations.count)
        locations.append(new)
    }

    private static func seedLocations() -> [Location] {
        let house = Location(name: "Home", type: .house)
        
        let kitchen  = Location(parentId: house.id, name: "Kitchen", type: .room)
        let garage   = Location(parentId: house.id, name: "Garage", type: .room)
        let cabinetA = Location(parentId: kitchen.id, name: "Cabinet A", type: .cabinet)
        let drawer1  = Location(parentId: cabinetA.id, name: "Drawer 1", type: .drawer)

        return [house, kitchen, garage, cabinetA, drawer1]
            .enumerated()
            .map { idx, loc in
                var copy = loc
                copy.sortOrder = idx
                return copy
            }
    }
}
