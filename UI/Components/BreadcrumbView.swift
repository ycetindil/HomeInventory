import SwiftUI

struct BreadcrumbView: View {
    let path: [Location]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(path.enumerated()), id: \.element.id) { index, location in
                    HStack(spacing: 8) {
                        Text(location.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        if index < path.count - 1 {
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(.regularMaterial)
    }
}

