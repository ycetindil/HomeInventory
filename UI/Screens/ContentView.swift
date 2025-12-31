import SwiftUI

struct ContentView: View {
    @Environment(LocationsViewModel.self) private var vm

    var body: some View {
        NavigationStack {
            LocationView(vm: vm, parent: nil)
                .navigationTitle("Locations")
        }
    }
}

#Preview {
    ContentView()
        .environment(LocationsViewModel())
}
