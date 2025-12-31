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

// MARK: - Item

public struct Item: Identifiable, Codable, Hashable {
    public let id: UUID
    public var locationId: UUID? // The room/box it lives in
    public var name: String
    public var note: String?
    public var quantity: Int
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        locationId: UUID? = nil,
        name: String,
        note: String? = nil,
        quantity: Int = 1,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.locationId = locationId
        self.name = name
        self.note = note
        self.quantity = quantity
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Hotspot

public struct Hotspot: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public let mapImageId: UUID       // The ID of the image this hotspot belongs to
    public let targetLocationId: UUID // The ID of the Location this hotspot links to
    public let x: Double              // Normalized X position (0.0 - 1.0)
    public let y: Double              // Normalized Y position (0.0 - 1.0)
    public let label: String?         // Optional text
    
    public init(id: UUID = UUID(), mapImageId: UUID, targetLocationId: UUID, x: Double, y: Double, label: String? = nil) {
        self.id = id
        self.mapImageId = mapImageId
        self.targetLocationId = targetLocationId
        self.x = x
        self.y = y
        self.label = label
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
    
    public var iconName: String {
        switch self {
        case .room:
            return "door.left.hand.closed"
        case .shelf:
            return "books.vertical"
        case .bin:
            return "shippingbox"
        case .other:
            return "folder"
        case .house:
            return "house.fill"
        case .cabinet:
            return "square.stack.3d.up.fill"
        case .drawer:
            return "tray.fill"
        case .zone:
            return "square.dashed"
        }
    }
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
