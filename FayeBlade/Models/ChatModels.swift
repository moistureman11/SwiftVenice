import Foundation
import SwiftData

@Model
class ChatMessage: Identifiable {
    @Attribute(.unique) var id: UUID
    var role: String
    var content: String
    var timestamp: Date

    init(id: UUID = UUID(), role: String, content: String, timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}

// These structs are for API communication and do not need to be SwiftData models.
struct ChatRequest: Codable {
    let model: String
    let messages: [ApiChatMessage]
    let stream: Bool = false
}

struct ApiChatMessage: Codable {
    let role: String
    let content: String
}

struct ChatResponse: Codable {
    let choices: [ChatChoice]
}

struct ChatChoice: Codable {
    let message: ApiChatMessage
}
