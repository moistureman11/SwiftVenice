import Foundation
import SwiftUI
import Combine

@MainActor
class ImageGenerationViewModel: ObservableObject {
    @Published var prompt: String = ""
    @Published var generatedImage: Image?
    @Published var isLoading: Bool = false

    private let networkManager = NetworkManager()

    func generateImage() {
        guard !prompt.isEmpty else { return }

        isLoading = true
        generatedImage = nil

        let request = ImageGenerationRequest(model: "hidream", prompt: prompt)

        networkManager.generateImage(request: request) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    if let base64String = response.images.first,
                       let imageData = Data(base64Encoded: base64String),
                       let uiImage = UIImage(data: imageData) {
                        self?.generatedImage = Image(uiImage: uiImage)
                    } else {
                        // Handle error: could not decode image
                        print("Failed to decode image")
                    }
                case .failure(let error):
                    // Handle error appropriately in a real app
                    print("Error generating image: \(error)")
                }
            }
        }
    }
}
