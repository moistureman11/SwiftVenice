import Foundation

struct UpscaleImageRequest: Codable {
    let image: String // Base64 encoded string of the image data
    let scale: Double
    let enhance: Bool
    let enhancePrompt: String?
    let enhanceCreativity: Double?

}
