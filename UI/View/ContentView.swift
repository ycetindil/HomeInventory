import SwiftUI

struct ContentView: View {
    @State private var vm = LocationsViewModel()

    var body: some View {
        NavigationStack {
            LocationTreeView(vm: vm, parent: nil)
                .navigationTitle("Locations")
        }
    }
}

#Preview {
    ContentView()
}
