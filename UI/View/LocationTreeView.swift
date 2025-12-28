import SwiftUI

struct LocationTreeView: View {
    let vm: LocationsViewModel
    let parent: Location?   // nil = roots

    @State private var showingAdd = false

    var body: some View {
        let list = (parent == nil)
            ? vm.roots
            : vm.children(of: parent!.id)

        List(list) { loc in
            NavigationLink {
                LocationTreeView(vm: vm, parent: loc)
                    .navigationTitle(loc.name)
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(loc.name).font(.headline)
                        Text(loc.type.rawValue)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    let count = vm.childCount(of: loc.id)
                    if count > 0 {
                        Text("\(count)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.thinMaterial)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAdd = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Location")
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddLocationSheet(vm: vm, parent: parent)
        }
    }
}

#Preview {
    NavigationStack {
        LocationTreeView(vm: LocationsViewModel(), parent: nil)
            .navigationTitle("Locations")
    }
}
