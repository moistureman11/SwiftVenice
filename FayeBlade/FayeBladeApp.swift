import SwiftUI
import SwiftData

@main
struct FayeBladeApp: App {
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
        .modelContainer(for: [ChatMessage.self, GeneratedImage.self, PromptTemplate.self])
    }
}
