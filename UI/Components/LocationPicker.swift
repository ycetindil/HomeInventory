import SwiftUI

struct LocationPicker: View {
    @Environment(LocationsViewModel.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selection: UUID?
    let blockedIds: Set<UUID>
    let currentParentId: UUID?
    let originId: UUID?
    let title: String
    let rootTitle: String
    
    init(selection: Binding<UUID?>, blockedIds: Set<UUID>, currentParentId: UUID? = nil, originId: UUID? = nil, title: String = "Move to...", rootTitle: String = "Move to Top Level") {
        self._selection = selection
        self.blockedIds = blockedIds
        self.currentParentId = currentParentId
        self.originId = originId
        self.title = title
        self.rootTitle = rootTitle
    }
    
    var body: some View {
        List {
            // 1. Move to Root Button (always visible)
            Button {
                selection = nil
                dismiss()
            } label: {
                Label(rootTitle, systemImage: "house")
            }
            
            // 2. Select Current Folder Button (only show if not at root and not redundant)
            if let currentId = currentParentId, currentId != originId {
                Button {
                    selection = currentId
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle")
                            .foregroundStyle(.green)
                        Text("Select This Folder ('\(title)')")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
            }
            
            // 3. Folder List
            if filteredLocations.isEmpty {
                ContentUnavailableView(
                    "Empty Folder",
                    systemImage: "folder.open",
                    description: Text("There are no sub-locations here.")
                )
            } else {
                ForEach(filteredLocations) { location in
                    locationRow(for: location)
                }
            }
        }
        .navigationTitle(title)
    }
    
    @ViewBuilder
    private func locationRow(for location: Location) -> some View {
        let isBlocked = blockedIds.contains(location.id)
        let hasChildren = !vm.locations.filter { $0.parentId == location.id }.isEmpty
        
        if hasChildren {
            // Has children - show NavigationLink to drill down
            HStack {
                NavigationLink {
                    LocationPicker(
                        selection: $selection,
                        blockedIds: blockedIds,
                        currentParentId: location.id,
                        originId: originId,
                        title: location.name,
                        rootTitle: rootTitle
                    )
                    .environment(vm)
                } label: {
                    HStack {
                        Image(systemName: location.type.iconName)
                            .foregroundStyle(.yellow)
                        Text(location.name)
                            .foregroundStyle(isBlocked ? .secondary : .primary)
                        Spacer()
                    }
                }
                .disabled(isBlocked)
                
                // Select button (only if not blocked)
                if !isBlocked {
                    Button {
                        selection = location.id
                        dismiss()
                    } label: {
                        Image(systemName: selection == location.id ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)
                }
            }
        } else {
            // Leaf node - no NavigationLink, just plain row
            HStack {
                Image(systemName: location.type.iconName)
                    .foregroundStyle(.yellow)
                Text(location.name)
                    .foregroundStyle(isBlocked ? .secondary : .primary)
                Spacer()
                
                // Select button (only if not blocked)
                if !isBlocked {
                    Button {
                        selection = location.id
                        dismiss()
                    } label: {
                        Image(systemName: selection == location.id ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    // Computed property for filtered locations
    private var filteredLocations: [Location] {
        if currentParentId == nil {
            // Filter for root locations (parentId == nil)
            return vm.locations.filter { $0.parentId == nil }
        } else {
            // Filter for children of currentParentId
            return vm.locations.filter { $0.parentId == currentParentId }
        }
    }
}
