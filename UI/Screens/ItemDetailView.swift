import SwiftUI

struct ItemDetailView: View {
    let vm: LocationsViewModel
    let item: Item
    
    @State private var isEditing = false
    @State private var draftItem: Item
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false
    
    init(vm: LocationsViewModel, item: Item, initialEditMode: Bool = false) {
        self.vm = vm
        self.item = item
        _draftItem = State(initialValue: item)
        _isEditing = State(initialValue: initialEditMode)
    }
    
    private var itemLocation: Location? {
        vm.location(for: item)
    }
    
    private var currentLocationName: String {
        if let locationId = draftItem.locationId,
           let location = vm.location(id: locationId) {
            return location.name
        }
        return "Top Level"
    }
    
    private var breadcrumbPath: [Location] {
        guard let location = itemLocation else { return [] }
        return vm.breadcrumbPath(for: location)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Breadcrumb navigation
            if !breadcrumbPath.isEmpty {
                BreadcrumbView(path: breadcrumbPath)
            }
            
            Form {
                if !isEditing {
                    readOnlyContent
                } else {
                    editingContent
                }
            }
        }
        .navigationTitle(isEditing ? "Edit Item" : draftItem.name)
        .toolbar {
            if !isEditing {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        isEditing = true
                    }
                }
            } else {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveDraft()
                        isEditing = false
                    }
                    .disabled(draftItem.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private var readOnlyContent: some View {
        Group {
            Section("Details") {
                HStack {
                    Text("Name")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(draftItem.name)
                        .foregroundStyle(.primary)
                }
                
                HStack {
                    Text("Quantity")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(draftItem.quantity)")
                        .foregroundStyle(.primary)
                }
                
                HStack {
                    Text("Location")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(currentLocationName)
                        .foregroundStyle(.primary)
                }
                
                if let note = draftItem.note, !note.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                        Text(note)
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
    }
    
    private var editingContent: some View {
        Group {
            Section("Details") {
                TextField("Name", text: $draftItem.name)
                
                Stepper(value: $draftItem.quantity, in: 1...999) {
                    HStack {
                        Text("Quantity")
                        Spacer()
                        Text("\(draftItem.quantity)")
                            .foregroundStyle(.secondary)
                    }
                }
                
                NavigationLink {
                    LocationPicker(
                        selection: Binding(
                            get: { draftItem.locationId },
                            set: { newId in
                                draftItem.locationId = newId
                            }
                        ),
                        blockedIds: [],
                        currentParentId: nil,
                        originId: item.locationId,
                        title: "Move to...",
                        rootTitle: "Remove from Location (Unassign)"
                    )
                    .environment(vm)
                } label: {
                    HStack {
                        Text("Location")
                        Spacer()
                        Text(currentLocationName)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Section("Notes") {
                TextEditor(text: Binding(
                    get: { draftItem.note ?? "" },
                    set: { draftItem.note = $0.isEmpty ? nil : $0 }
                ))
                .frame(minHeight: 100)
            }
            
            Section {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Text("Delete Item")
                }
                .confirmationDialog("Delete Item?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        vm.deleteItem(draftItem.id)
                        dismiss()
                    }
                } message: {
                    Text("Are you sure you want to delete this item? This action cannot be undone.")
                }
            }
        }
    }
    
    private func saveDraft() {
        let trimmedName = draftItem.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        let trimmedNote = draftItem.note?.trimmingCharacters(in: .whitespacesAndNewlines)
        vm.updateItem(item, name: trimmedName, quantity: draftItem.quantity, note: trimmedNote?.isEmpty == true ? nil : trimmedNote)
        
        // Handle location move if changed
        if draftItem.locationId != item.locationId {
            vm.moveItem(item, to: draftItem.locationId)
        }
    }
}

