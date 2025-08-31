import Foundation
import SwiftData
import SwiftUI

@Model
class GeneratedImage {
    @Attribute(.unique) var id: UUID
    var prompt: String
    var imageData: Data
    var timestamp: Date

    init(id: UUID = UUID(), prompt: String, imageData: Data, timestamp: Date = Date()) {
        self.id = id
        self.prompt = prompt
        self.imageData = imageData
        self.timestamp = timestamp
    }
}
