import SwiftUI

struct LocationSettingsView: View {
    let vm: LocationsViewModel
    let location: Location
    
    @State private var draftLocation: Location
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false
    
    init(vm: LocationsViewModel, location: Location) {
        self.vm = vm
        self.location = location
        _draftLocation = State(initialValue: location)
    }
    
    private var currentParentName: String {
        if let parentId = draftLocation.parentId,
           let parent = vm.location(id: parentId) {
            return parent.name
        }
        return "Top Level"
    }
    
    var body: some View {
        Form {
            Section("Info") {
                TextField("Name", text: $draftLocation.name)
                
                Picker("Type", selection: $draftLocation.type) {
                    ForEach(LocationType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
            }
            
            Section("Move") {
                NavigationLink {
                    LocationPicker(
                        selection: Binding(
                            get: { draftLocation.parentId },
                            set: { newId in
                                draftLocation.parentId = newId
                            }
                        ),
                        blockedIds: vm.allDescendantIds(of: location.id).union([location.id]),
                        currentParentId: nil,
                        originId: location.parentId,
                        title: "Parent Folder"
                    )
                    .environment(vm)
                } label: {
                    HStack {
                        Text("Parent Folder")
                        Spacer()
                        Text(currentParentName)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Section {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Text("Delete Location")
                }
                .confirmationDialog("Delete Location?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        vm.deleteLocation(location.id)
                        dismiss()
                    }
                } message: {
                    Text("Are you sure you want to delete this folder? This will also delete all sub-locations and items within it.")
                }
            }
        }
        .navigationTitle("Location Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let trimmed = draftLocation.name.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    
                    // Update name and type
                    vm.updateLocation(location, newName: trimmed, type: draftLocation.type)
                    
                    // Handle move if parent changed
                    if draftLocation.parentId != location.parentId {
                        do {
                            try vm.moveLocation(location, to: draftLocation.parentId)
                        } catch {
                            print("Error moving location: \(error.localizedDescription)")
                        }
                    }
                    
                    dismiss()
                }
                .disabled(draftLocation.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}

