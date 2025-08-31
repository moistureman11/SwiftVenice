import Foundation

struct ImageGenerationRequest: Codable {
    let model: String
    let prompt: String
    let negative_prompt: String?
    let width: Int
    let height: Int
    let steps: Int
    let cfg_scale: Double
    let style_preset: String?

    // The API might not support `n` directly in this endpoint,
    // but we include it for future use or for the view model to handle.
    // let n: Int
}

struct ImageGenerationResponse: Codable {
    let images: [String]
}
