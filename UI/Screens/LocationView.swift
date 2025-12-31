import SwiftUI
import PhotosUI // <--- Required for the picker

struct LocationView: View {
    let vm: LocationsViewModel
    let parent: Location?   // nil = roots
    
    // State for Adding Sub-locations and Items
    @State private var showingAddLocation = false
    @State private var showingAddItem = false
    @State private var newItemName = ""
    
    // State for Photo Picker
    @State private var selectedPhoto: PhotosPickerItem?
    
    // State for async image loading
    @State private var loadedImage: UIImage?
    
    // State for hotspot editing
    @State private var isEditingMap = false
    @State private var pendingHotspotCoords: (x: Double, y: Double)?
    @State private var showingAddHotspotAlert = false
    @State private var newLocationName = ""
    @State private var navigationTarget: Location? // For hotspot navigation
    
    // Get the latest location data from VM
    private var currentLocation: Location? {
        guard let parent = parent else { return nil }
        return vm.location(with: parent.id) ?? parent
    }
    
    // Filter hotspots for the current map image
    private var currentHotspots: [Hotspot] {
        guard let currentLoc = currentLocation,
              let mapImageId = currentLoc.primaryMapImageId else { return [] }
        return vm.hotspots.filter { $0.mapImageId == mapImageId }
    }
    
    var body: some View {
        List {
            // --- SECTION 0: ROOM PHOTO (Only if we are inside a location) ---
            if let currentLoc = currentLocation {
                Section {
                    // A. Show the HotspotImageView (if we have an image) or placeholder
                    if currentLoc.primaryMapImageId != nil {
                        HotspotImageView(
                            imageState: loadedImage,
                            hotspots: currentHotspots,
                            isEditing: isEditingMap,
                            onAddHotspot: { x, y in
                                pendingHotspotCoords = (x: x, y: y)
                                newLocationName = ""
                                showingAddHotspotAlert = true
                            },
                            onSelectHotspot: { hotspot in
                                if let targetLocation = vm.location(with: hotspot.targetLocationId) {
                                    navigationTarget = targetLocation
                                }
                            }
                        )
                        .frame(height: 250)
                        .listRowInsets(EdgeInsets())
                        .id(currentLoc.primaryMapImageId)
                        .task(id: currentLoc.primaryMapImageId) {
                            loadedImage = await vm.image(for: currentLoc)
                        }
                    } else {
                        ContentUnavailableView("No Room Photo", systemImage: "camera")
                            .frame(height: 150)
                            .foregroundStyle(.secondary)
                    }
                    
                    // B. The Button to Add/Change Photo
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label(
                            currentLoc.primaryMapImageId == nil ? "Add Photo" : "Change Photo",
                            systemImage: "photo.badge.plus"
                        )
                        .frame(maxWidth: .infinity)
                        .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderless) // Fixes clickability in List
                    .onChange(of: selectedPhoto) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                vm.setImage(uiImage, for: currentLoc.id)
                                // The .task(id: currentLoc.primaryMapImageId) will automatically reload the image
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
                        LocationView(vm: vm, parent: loc)
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
            if let currentLoc = currentLocation, currentLoc.primaryMapImageId != nil {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditingMap ? "Done" : "Edit Map") {
                        isEditingMap.toggle()
                    }
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
        // Alert: Add Hotspot Location
        .alert("Add Location", isPresented: $showingAddHotspotAlert) {
            TextField("Location Name", text: $newLocationName)
            Button("Cancel", role: .cancel) {
                pendingHotspotCoords = nil
            }
            Button("Add") {
                handleCreateHotspot()
            }
        } message: {
            Text("Enter a name for the location at this hotspot")
        }
        // Navigation destination for hotspot navigation
        .navigationDestination(item: $navigationTarget) { targetLocation in
            LocationView(vm: vm, parent: targetLocation)
                .navigationTitle(targetLocation.name)
        }
        .task {
            // Load image asynchronously when view appears
            if let currentLoc = currentLocation {
                loadedImage = await vm.image(for: currentLoc)
            }
        }
        .onChange(of: parent?.id) {
            // Reload image when location changes
            Task {
                if let currentLoc = currentLocation {
                    loadedImage = await vm.image(for: currentLoc)
                } else {
                    loadedImage = nil
                }
            }
        }
    }
    
    private func handleCreateHotspot() {
        guard let coords = pendingHotspotCoords,
              let currentLoc = currentLocation,
              let mapImageId = currentLoc.primaryMapImageId,
              !newLocationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        // Add the new location
        vm.addLocation(
            name: newLocationName.trimmingCharacters(in: .whitespacesAndNewlines),
            type: .room,
            parentId: currentLoc.id
        )
        
        // Find the newly created location (most recently added with matching parentId and name)
        if let newLocation = vm.locations.first(where: {
            $0.parentId == currentLoc.id &&
            $0.name == newLocationName.trimmingCharacters(in: .whitespacesAndNewlines)
        }) {
            // Add Hotspot to newLocation
            vm.addHotspot(
                locationId: newLocation.id,
                x: coords.x,
                y: coords.y,
                mapImageId: mapImageId
            )
        }
        // Reset state
        pendingHotspotCoords = nil
        newLocationName = ""
    }
}

