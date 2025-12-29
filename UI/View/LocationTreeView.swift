import SwiftUI
import PhotosUI // <--- Required for the picker

struct LocationTreeView: View {
    let vm: LocationsViewModel
    let parent: Location?   // nil = roots
    
    // State for Adding Sub-locations and Items
    @State private var showingAddLocation = false
    @State private var showingAddItem = false
    @State private var newItemName = ""
    
    // State for Photo Picker
    @State private var selectedPhoto: PhotosPickerItem?
    
    var body: some View {
        List {
            // --- SECTION 0: ROOM PHOTO (Only if we are inside a location) ---
            if let currentLoc = parent {
                Section {
                    // 1. The Image
                    if let image = vm.image(for: currentLoc) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .listRowInsets(EdgeInsets())
                            .clipped()
                    } else {
                        // Placeholder
                        HStack {
                            Spacer()
                            VStack {
                                Image(systemName: "camera")
                                    .font(.title)
                                Text("No Room Photo")
                                    .font(.caption)
                            }
                            .foregroundStyle(.secondary)
                            .frame(height: 100)
                            Spacer()
                        }
                    }
                    
                    // 2. The Picker Button
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label(currentLoc.primaryMapImageId == nil ? "Add Photo" : "Change Photo", systemImage: "photo")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderless) // Fixes clickability in List
                    .onChange(of: selectedPhoto) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                vm.setImage(uiImage, for: currentLoc.id)
                            }
                        }
                    }
                } header: {
                    Text("Room Map")
                }
            }
            
            // --- SECTION 1: SUB-LOCATIONS (The "Folders") ---
            Section("Locations") {
                let subLocations = (parent == nil)
                    ? vm.roots
                    : vm.children(of: parent!.id)
                
                if subLocations.isEmpty {
                    Text("No sub-locations")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                
                ForEach(subLocations) { loc in
                    NavigationLink {
                        LocationTreeView(vm: vm, parent: loc)
                            .navigationTitle(loc.name)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(loc.name).font(.headline)
                                Text(loc.type.rawValue).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            let count = vm.childCount(of: loc.id)
                            if count > 0 {
                                Text("\(count)")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.quaternary)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            
            // --- SECTION 2: ITEMS (The "Files") ---
            if let parentLocation = parent {
                Section("Items") {
                    let items = vm.items(for: parentLocation.id)
                    
                    if items.isEmpty {
                        Text("No items")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                    
                    ForEach(items) { item in
                        HStack {
                            Image(systemName: "box.truck.fill")
                                .foregroundStyle(.blue)
                            Text(item.name)
                        }
                    }
                    
                    Button {
                        newItemName = ""
                        showingAddItem = true
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
        // Toolbar
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddLocation = true
                } label: {
                    Image(systemName: "folder.badge.plus")
                }
            }
        }
        // Sheet: Add Location
        .sheet(isPresented: $showingAddLocation) {
            AddLocationSheet(vm: vm, parent: parent)
        }
        // Alert: Add Item
        .alert("Add Item", isPresented: $showingAddItem) {
            TextField("Item Name", text: $newItemName)
            Button("Cancel", role: .cancel) { }
            Button("Add") {
                if !newItemName.isEmpty, let parentId = parent?.id {
                    vm.addItem(name: newItemName, parentId: parentId)
                }
            }
        } message: {
            Text("What is stored in \(parent?.name ?? "this location")?")
        }
    }
}
