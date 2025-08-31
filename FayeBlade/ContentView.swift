import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selection: Screen? = .imageGeneration
    @StateObject private var settings = SettingsStore()
    @Environment(\.modelContext) private var modelContext

    enum Screen {
        case imageGeneration
        case chat
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                NavigationLink(value: Screen.imageGeneration) {
                    Label("Image Generation", systemImage: "photo.on.rectangle.angled")
                }
                NavigationLink(value: Screen.chat) {
                    Label("Chat", systemImage: "message")
                }

                SettingsView()

            }
            .listStyle(SidebarListStyle())
            .navigationTitle("FayeBlade")
        } detail: {
            switch selection {
            case .imageGeneration:
                ImageGenerationView(viewModel: ImageGenerationViewModel(settings: settings, modelContext: modelContext))
            case .chat:
                ChatView(modelContext: modelContext)
            case .none:
                Text("Select an option")
            }
        }
        .environmentObject(settings)
    }
}
