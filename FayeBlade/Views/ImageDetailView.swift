import SwiftUI

struct ImageDetailView: View {
    @StateObject var viewModel: ImageDetailViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let originalUiImage = UIImage(data: viewModel.originalImage.imageData) {
                    Image(uiImage: originalUiImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                }

                Text(viewModel.originalImage.prompt)
                    .font(Theme.appFont(size: 16))
                    .foregroundColor(Theme.textSecondary)
                    .padding()

                HStack(spacing: 15) {
                    Button("2x Upscale") {
                        viewModel.upscaleImage(scale: 2.0, enhance: false)
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button("Enhance") {
                        viewModel.upscaleImage(scale: 1.0, enhance: true)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }

                if viewModel.isLoading {
                    ProgressView()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else if let upscaledImage = viewModel.upscaledImage {
                    VStack {
                        Text("Upscaled/Enhanced Result").font(.headline)
                        upscaledImage
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .background(Theme.backgroundColor.edgesIgnoringSafeArea(.all))
        .navigationTitle("Image Detail")
    }
}
