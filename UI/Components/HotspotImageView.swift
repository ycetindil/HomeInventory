import SwiftUI

struct HotspotImageView: View {
    let imageState: UIImage?
    let hotspots: [Hotspot]
    let isEditing: Bool
    let onAddHotspot: (Double, Double) -> Void
    let onSelectHotspot: (Hotspot) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // Background Image
                if let image = imageState {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } else {
                    // Placeholder when no image
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
                
                // Tap Gesture for Adding Hotspots (Edit Mode only)
                // This layer is below hotspots so hotspots take tap priority
                if isEditing {
                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onEnded { value in
                                    // Calculate normalized coordinates (0.0 - 1.0)
                                    let normalizedX = max(0.0, min(1.0, value.location.x / geometry.size.width))
                                    let normalizedY = max(0.0, min(1.0, value.location.y / geometry.size.height))
                                    onAddHotspot(normalizedX, normalizedY)
                                }
                        )
                }
                
                // Hotspot Overlays (rendered on top, so their gestures take priority)
                ForEach(hotspots) { hotspot in
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .position(
                            x: CGFloat(hotspot.x) * geometry.size.width,
                            y: CGFloat(hotspot.y) * geometry.size.height
                        )
                        .onTapGesture {
                            onSelectHotspot(hotspot)
                        }
                }
            }
        }
    }
}

