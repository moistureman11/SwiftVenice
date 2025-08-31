import Foundation

struct ImageGenerationRequest: Codable {
    let model: String
    let prompt: String
    let negative_prompt: String? = nil
    let width: Int = 1024
    let height: Int = 1024
    let steps: Int = 20
}

struct ImageGenerationResponse: Codable {
    let images: [String]
}
