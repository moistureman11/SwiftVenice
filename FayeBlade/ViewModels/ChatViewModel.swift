import Foundation
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentInput: String = ""

    private let networkManager = NetworkManager()

    func sendMessage() {
        guard !currentInput.isEmpty else { return }

        let userMessage = ChatMessage(role: "user", content: currentInput)
        messages.append(userMessage)
        currentInput = ""

        let request = ChatRequest(model: "venice-uncensored", messages: messages)

        networkManager.getChatCompletion(request: request) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let assistantMessage = response.choices.first?.message {
                        self?.messages.append(assistantMessage)
                    }
                case .failure(let error):
                    // Handle error appropriately in a real app
                    print("Error getting chat completion: \(error)")
                    let errorMessage = ChatMessage(role: "assistant", content: "Sorry, I encountered an error.")
                    self?.messages.append(errorMessage)
                }
            }
        }
    }
}
