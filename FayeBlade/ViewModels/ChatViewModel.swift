import Foundation
import SwiftData
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentInput: String = ""

    private var modelContext: ModelContext
    private var settings: SettingsStore
    private let networkManager = NetworkManager()

    init(modelContext: ModelContext, settings: SettingsStore) {
        self.modelContext = modelContext
        self.settings = settings
        fetchMessages()
    }

    func fetchMessages() {
        do {
            let descriptor = FetchDescriptor<ChatMessage>(sortBy: [SortDescriptor(\.timestamp)])
            messages = try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching messages: \(error)")
        }
    }

    func sendMessage() {
        guard !currentInput.isEmpty else { return }

        let userMessage = ChatMessage(role: "user", content: currentInput)
        modelContext.insert(userMessage)
        messages.append(userMessage)

        let apiMessages = messages.map { ApiChatMessage(role: $0.role, content: $0.content) }
        let request = ChatRequest(model: "venice-uncensored", messages: apiMessages, safe: settings.safeMode)

        currentInput = ""

        networkManager.getChatCompletion(request: request) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    if let assistantMessageContent = response.choices.first?.message.content {
                        let assistantMessage = ChatMessage(role: "assistant", content: assistantMessageContent)
                        self.modelContext.insert(assistantMessage)
                        self.messages.append(assistantMessage)
                    }
                case .failure(let error):
                    print("Error getting chat completion: \(error)")
                    let errorMessage = ChatMessage(role: "assistant", content: "Sorry, I encountered an error.")
                    // Do not save error messages to the context
                    self.messages.append(errorMessage)
                }
            }
        }
    }
}
