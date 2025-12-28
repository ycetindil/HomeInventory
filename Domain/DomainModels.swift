import Foundation

// MARK: - Location

public struct Location: Identifiable, Codable, Hashable {
    public let id: UUID
    public var parentId: UUID?
    public var name: String
    public var type: LocationType
    public var sortOrder: Int
    public var primaryMapImageId: UUID?
    public var notes: String?
    public var createdAt: Date
    public var updatedAt: Date
    public var deletedAt: Date?

    public init(
        id: UUID = UUID(),
        parentId: UUID? = nil,
        name: String,
        type: LocationType = .other,
        sortOrder: Int = 0,
        primaryMapImageId: UUID? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.parentId = parentId
        self.name = name
        self.type = type
        self.sortOrder = sortOrder
        self.primaryMapImageId = primaryMapImageId
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}

// MARK: - LocationType

public enum LocationType: String, Codable, CaseIterable, Hashable {
    case house
    case room
    case cabinet
    case drawer
    case bin
    case shelf
    case zone
    case other
}

// MARK: - Preview / Dev Seed Data

public extension Location {
    /// Deterministic sample data for SwiftUI previews.
    static var previewLocations: [Location] {
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
