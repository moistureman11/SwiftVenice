import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
class ImageGenerationViewModel: ObservableObject {
    @Published var prompt: String = ""
    @Published var generatedImage: Image?
    @Published var isLoading: Bool = false
    @Published var generationHistory: [GeneratedImage] = []

    private var settings: SettingsStore
    private var modelContext: ModelContext
    private let networkManager = NetworkManager()

    init(settings: SettingsStore, modelContext: ModelContext) {
        self.settings = settings
        self.modelContext = modelContext
        fetchHistory()
    }

    func fetchHistory() {
        do {
            let descriptor = FetchDescriptor<GeneratedImage>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
            generationHistory = try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching image generation history: \(error)")
        }
    }

    func generateImage() {
        guard !prompt.isEmpty else { return }

        isLoading = true
        generatedImage = nil

        let (width, height) = parseAspectRatio(settings.aspectRatio)

        let request = ImageGenerationRequest(
            model: settings.model,
            prompt: prompt,
            negative_prompt: nil,
            width: width,
            height: height,
            steps: Int(settings.variants),
            cfg_scale: settings.guidance,
            style_preset: settings.style
        )

        networkManager.generateImage(request: request) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let response):
                    if let base64String = response.images.first,
                       let imageData = Data(base64Encoded: base64String) {

                        let newImage = GeneratedImage(prompt: self.prompt, imageData: imageData)
                        self.modelContext.insert(newImage)
                        self.generationHistory.insert(newImage, at: 0)

                        if let uiImage = UIImage(data: imageData) {
                            self.generatedImage = Image(uiImage: uiImage)
                        }
                    } else {
                        print("Failed to decode image")
                    }
                case .failure(let error):
                    print("Error generating image: \(error)")
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
