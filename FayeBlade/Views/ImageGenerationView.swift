import SwiftUI

struct ImageGenerationView: View {
    @ObservedObject var viewModel: ImageGenerationViewModel
    @State private var negativePrompt: String = ""
    @State private var selectedTab = "History"

    private let columns = [GridItem(.adaptive(minimum: 150))]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("AI Image Generation")
                    .font(Theme.appFont(size: 32, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                VStack(alignment: .leading) {
                    Text("Prompt").font(Theme.appFont(size: 14, weight: .medium)).foregroundColor(Theme.textSecondary)
                    TextEditor(text: $viewModel.prompt)
                        .frame(height: 100)
                        .padding(4)
                        .background(Theme.secondaryColor)
                        .cornerRadius(8)
                        .foregroundColor(Theme.textPrimary)
                }

                VStack(alignment: .leading) {
                    Text("Negative Prompt").font(Theme.appFont(size: 14, weight: .medium)).foregroundColor(Theme.textSecondary)
                    TextEditor(text: $negativePrompt)
                        .frame(height: 50)
                        .padding(4)
                        .background(Theme.secondaryColor)
                        .cornerRadius(8)
                        .foregroundColor(Theme.textPrimary)
                }

                Button("Generate") {
                    viewModel.generateImage()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Theme.primaryColor)
                .foregroundColor(.white)
                .font(Theme.appFont(size: 18, weight: .bold))
                .cornerRadius(8)
                .disabled(viewModel.isLoading)

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }

                Picker("Tabs", selection: $selectedTab) {
                    Text("Generation History").tag("History")
                    Text("My Collection").tag("Collection")
                }
                .pickerStyle(SegmentedPickerStyle())

                if selectedTab == "History" {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.generationHistory) { image in
                            NavigationLink(destination: ImageDetailView(viewModel: ImageDetailViewModel(image: image))) {
                                if let uiImage = UIImage(data: image.imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                } else {
                    // Placeholder for "My Collection"
                    Text("Your collection will be here.")
                        .foregroundColor(Theme.textSecondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding()
        }
        .background(Theme.backgroundColor)
        .navigationTitle("Image Generation")
        .navigationBarHidden(true)
    }
}
