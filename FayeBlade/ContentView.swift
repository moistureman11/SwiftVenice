import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selection: Screen? = .imageGeneration
    @StateObject private var settings = SettingsStore()
    @Environment(\.modelContext) private var modelContext

    enum Screen {
        case imageGeneration
        case batchGeneration
        case promptTemplates
        case chat
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                NavigationLink(value: Screen.imageGeneration) {
                    Label("Image Generation", systemImage: "photo.on.rectangle.angled")
                }
                NavigationLink(value: Screen.batchGeneration) {
                    Label("Batch Generation", systemImage: "rectangle.3.group")
                }
                NavigationLink(value: Screen.promptTemplates) {
                    Label("Prompt Templates", systemImage: "doc.text.below.ecg")
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
            case .batchGeneration:
                BatchGenerationView(settings: settings, modelContext: modelContext)
            case .promptTemplates:
                PromptTemplatesView { selectedPrompt in
                    // Handle template selection if needed
                }
            case .chat:
                ChatView(modelContext: modelContext, settings: settings)
            case .none:
                Text("Select an option")
            }
        }
        .environmentObject(settings)
    }
}
