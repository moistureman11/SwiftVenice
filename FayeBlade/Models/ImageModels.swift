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
    let safe: Bool  // CSAM filter - disabled for dev mode testing
    
    init(model: String, prompt: String, negative_prompt: String? = nil, width: Int, height: Int, steps: Int, cfg_scale: Double, style_preset: String? = nil, safe: Bool = true) {
        self.model = model
        self.prompt = prompt
        self.negative_prompt = negative_prompt
        self.width = width
        self.height = height
        self.steps = steps
        self.cfg_scale = cfg_scale
        self.style_preset = style_preset
        self.safe = safe
    }

    // The API might not support `n` directly in this endpoint,
    // but we include it for future use or for the view model to handle.
    // let n: Int
}

struct ImageGenerationResponse: Codable {
    let images: [String]
}
