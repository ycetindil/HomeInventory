import SwiftUI

// Handles saving and loading images from disk
actor ImageStore {
    // CHANGE: Made this a 'let' constant so it is safe to use in init()
    private let imagesDirectory: URL
    
    init() {
        // 1. Calculate the path once during initialization
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        self.imagesDirectory = paths[0].appendingPathComponent("Images")
        
        // 2. Create the folder if it doesn't exist
        try? FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
    }
    
    func save(_ image: UIImage, id: UUID) throws {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let url = imagesDirectory.appendingPathComponent("\(id.uuidString).jpg")
        try data.write(to: url)
    }
    
    func load(id: UUID) -> UIImage? {
        let url = imagesDirectory.appendingPathComponent("\(id.uuidString).jpg")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
    
    func delete(id: UUID) {
        let url = imagesDirectory.appendingPathComponent("\(id.uuidString).jpg")
        try? FileManager.default.removeItem(at: url)
    }
}
