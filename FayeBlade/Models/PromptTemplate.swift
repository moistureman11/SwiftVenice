import Foundation
import SwiftData

@Model
class PromptTemplate: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var prompt: String
    var category: String
    var isCustom: Bool
    var timestamp: Date
    
    init(id: UUID = UUID(), name: String, prompt: String, category: String, isCustom: Bool = false, timestamp: Date = Date()) {
        self.id = id
        self.name = name
        self.prompt = prompt
        self.category = category
        self.isCustom = isCustom
        self.timestamp = timestamp
    }
    
    // Predefined templates
    static let defaultTemplates: [PromptTemplate] = [
        PromptTemplate(name: "Portrait Photography", prompt: "professional portrait photography, studio lighting, high quality, detailed", category: "Photography"),
        PromptTemplate(name: "Landscape Art", prompt: "breathtaking landscape, golden hour lighting, cinematic composition, ultra detailed", category: "Art"),
        PromptTemplate(name: "Cyberpunk Style", prompt: "cyberpunk aesthetic, neon lights, futuristic cityscape, dark atmosphere", category: "Sci-Fi"),
        PromptTemplate(name: "Fantasy Concept", prompt: "fantasy art, magical atmosphere, ethereal lighting, mystical elements", category: "Fantasy"),
        PromptTemplate(name: "Minimalist Design", prompt: "minimalist design, clean lines, simple composition, modern aesthetic", category: "Design"),
        PromptTemplate(name: "Vintage Style", prompt: "vintage aesthetic, retro colors, nostalgic atmosphere, film grain", category: "Vintage"),
        PromptTemplate(name: "Abstract Art", prompt: "abstract art, vibrant colors, flowing forms, contemporary style", category: "Art"),
        PromptTemplate(name: "Architecture", prompt: "modern architecture, geometric forms, clean design, professional photography", category: "Architecture")
    ]
}