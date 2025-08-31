import Foundation
import SwiftUI
import Combine

@MainActor
class ImageDetailViewModel: ObservableObject {
    @Published var originalImage: GeneratedImage
    @Published var upscaledImage: Image?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let networkManager = NetworkManager()

    init(image: GeneratedImage) {
        self.originalImage = image
    }

    func upscaleImage(scale: Double, enhance: Bool) {
        isLoading = true
        errorMessage = nil
        upscaledImage = nil

        let base64String = originalImage.imageData.base64EncodedString()
        let request = UpscaleImageRequest(
            image: base64String,
            scale: scale,
            enhance: enhance,
            enhancePrompt: nil, // Not exposing this in the UI for now
            enhanceCreativity: nil
        )

        networkManager.upscaleImage(request: request) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let imageData):
                    if let uiImage = UIImage(data: imageData) {
                        self.upscaledImage = Image(uiImage: uiImage)
                    } else {
                        self.errorMessage = "Failed to decode upscaled image."
                    }
                case .failure(let error):
                    self.errorMessage = "Error upscaling image: \(error.localizedDescription)"
                }
            }
        }
    }
}
