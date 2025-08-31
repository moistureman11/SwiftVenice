import Foundation

struct ChatRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let stream: Bool = false
}

struct ChatMessage: Codable, Identifiable {
    let id = UUID()
    let role: String
    let content: String

    // Custom coding keys to exclude 'id' from JSON encoding/decoding
    enum CodingKeys: String, CodingKey {
        case role, content
    }
}

struct ChatResponse: Codable {
    let choices: [ChatChoice]
}

struct ChatChoice: Codable {
    let message: ChatMessage
}
