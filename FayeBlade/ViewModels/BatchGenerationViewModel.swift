import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
class BatchGenerationViewModel: ObservableObject {
    @Published var basePrompt: String = ""
    @Published var batchCount: Int = 4
    @Published var useRandomSeeds: Bool = true
    @Published var varyStyles: Bool = false
    @Published var isGenerating: Bool = false
    @Published var generatedImages: [GeneratedImage] = []
    @Published var progress: Double = 0.0
    @Published var completedCount: Int = 0
    
    private var settings: SettingsStore
    private var modelContext: ModelContext
    private let networkManager = NetworkManager()
    
    private let styleVariations = [
        "photorealistic", "artistic", "cinematic", "dramatic lighting",
        "soft lighting", "high contrast", "vibrant colors", "muted tones",
        "detailed", "minimalist", "vintage", "modern"
    ]
    
    init(settings: SettingsStore, modelContext: ModelContext) {
        self.settings = settings
        self.modelContext = modelContext
    }
    
    func generateBatch() {
        guard !basePrompt.isEmpty, !isGenerating else { return }
        
        isGenerating = true
        generatedImages = []
        progress = 0.0
        completedCount = 0
        
        // Generate variations of the prompt
        var prompts: [String] = []
        
        for i in 0..<batchCount {
            var currentPrompt = basePrompt
            
            if varyStyles && !styleVariations.isEmpty {
                let randomStyle = styleVariations.randomElement() ?? ""
                currentPrompt += ", \(randomStyle)"
            }
            
            // Add variation number for uniqueness
            if useRandomSeeds {
                currentPrompt += " (variation \(i + 1))"
            }
            
            prompts.append(currentPrompt)
        }
        
        // Generate images sequentially to avoid overwhelming the API
        generateImagesSequentially(prompts: prompts, index: 0)
    }
    
    private func generateImagesSequentially(prompts: [String], index: Int) {
        guard index < prompts.count else {
            // All images generated
            isGenerating = false
            return
        }
        
        let prompt = prompts[index]
        let (width, height) = parseAspectRatio(settings.aspectRatio)
        
        let request = ImageGenerationRequest(
            model: settings.model,
            prompt: prompt,
            negative_prompt: nil,
            width: width,
            height: height,
            steps: Int(settings.variants),
            cfg_scale: settings.guidance,
            style_preset: settings.style,
            safe: settings.safeMode
        )
        
        networkManager.generateImage(request: request) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    if let base64String = response.images.first,
                       let imageData = Data(base64Encoded: base64String) {
                        
                        let newImage = GeneratedImage(prompt: prompt, imageData: imageData)
                        self.modelContext.insert(newImage)
                        self.generatedImages.append(newImage)
                        
                        // Update progress
                        self.completedCount = index + 1
                        self.progress = Double(self.completedCount) / Double(self.batchCount)
                        
                        // Continue with next image
                        self.generateImagesSequentially(prompts: prompts, index: index + 1)
                    } else {
                        print("Failed to decode image for batch item \(index)")
                        // Continue with next image even if this one failed
                        self.completedCount = index + 1
                        self.progress = Double(self.completedCount) / Double(self.batchCount)
                        self.generateImagesSequentially(prompts: prompts, index: index + 1)
                    }
                    
                case .failure(let error):
                    print("Error generating batch image \(index): \(error)")
                    // Continue with next image even if this one failed
                    self.completedCount = index + 1
                    self.progress = Double(self.completedCount) / Double(self.batchCount)
                    self.generateImagesSequentially(prompts: prompts, index: index + 1)
                }
            }
        }
    }
    
    private func parseAspectRatio(_ ratio: String) -> (Int, Int) {
        switch ratio {
        case "3:4": return (768, 1024)
        case "4:3": return (1024, 768)
        case "16:9": return (1280, 720)
        case "1:1": fallthrough
        default: return (1024, 1024)
        }
    }
}