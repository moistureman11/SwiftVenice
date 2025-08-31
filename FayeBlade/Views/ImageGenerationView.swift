import SwiftUI

struct ImageGenerationView: View {
    @StateObject private var viewModel = ImageGenerationViewModel()

    var body: some View {
        VStack {
            TextField("Enter your image prompt...", text: $viewModel.prompt, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(5...10)
                .padding()

            Button("Generate Image") {
                viewModel.generateImage()
            }
            .disabled(viewModel.isLoading)
            .padding()

            if viewModel.isLoading {
                ProgressView()
                    .padding()
            }

            if let image = viewModel.generatedImage {
                image
                    .resizable()
                    .scaledToFit()
                    .padding()
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Image Generation")
    }
}
