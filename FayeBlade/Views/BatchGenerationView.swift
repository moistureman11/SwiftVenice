import SwiftUI
import SwiftData

struct BatchGenerationView: View {
    @StateObject private var viewModel: BatchGenerationViewModel
    @State private var showingTemplates = false
    
    init(settings: SettingsStore, modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: BatchGenerationViewModel(settings: settings, modelContext: modelContext))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Batch Generation")
                    .font(Theme.appFont(size: 24, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                
                Text("Generate multiple variations of your prompt simultaneously")
                    .font(Theme.appFont(size: 14))
                    .foregroundColor(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Prompt Input Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Prompt")
                                .font(Theme.appFont(size: 18, weight: .semibold))
                                .foregroundColor(Theme.textPrimary)
                            
                            Spacer()
                            
                            Button("Templates") {
                                showingTemplates = true
                            }
                            .font(Theme.appFont(size: 14))
                            .foregroundColor(Theme.primaryColor)
                        }
                        
                        TextEditor(text: $viewModel.basePrompt)
                            .frame(minHeight: 80)
                            .padding(12)
                            .background(Theme.secondaryColor)
                            .cornerRadius(10)
                            .font(Theme.appFont(size: 16))
                    }
                    .padding(.horizontal)
                    
                    // Batch Settings
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Batch Settings")
                            .font(Theme.appFont(size: 18, weight: .semibold))
                            .foregroundColor(Theme.textPrimary)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Number of Variations:")
                                    .font(Theme.appFont(size: 16))
                                Spacer()
                                Text("\(viewModel.batchCount)")
                                    .font(Theme.appFont(size: 16, weight: .semibold))
                                    .foregroundColor(Theme.primaryColor)
                            }
                            
                            Slider(value: Binding(
                                get: { Double(viewModel.batchCount) },
                                set: { viewModel.batchCount = Int($0) }
                            ), in: 1...8, step: 1)
                            .accentColor(Theme.primaryColor)
                        }
                        
                        Toggle("Use Random Seeds", isOn: $viewModel.useRandomSeeds)
                            .font(Theme.appFont(size: 16))
                        
                        Toggle("Vary Style Prompts", isOn: $viewModel.varyStyles)
                            .font(Theme.appFont(size: 16))
                    }
                    .padding()
                    .background(Theme.secondaryColor)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Generate Button
                    Button(action: viewModel.generateBatch) {
                        HStack {
                            if viewModel.isGenerating {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "rectangle.3.group")
                            }
                            
                            Text(viewModel.isGenerating ? "Generating..." : "Generate Batch")
                        }
                        .font(Theme.appFont(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Theme.primaryColor, Theme.primaryColor.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .disabled(viewModel.basePrompt.isEmpty || viewModel.isGenerating)
                    }
                    .padding(.horizontal)
                    
                    // Progress Indicator
                    if viewModel.isGenerating {
                        VStack(spacing: 8) {
                            ProgressView(value: viewModel.progress)
                                .progressViewStyle(LinearProgressViewStyle())
                                .accentColor(Theme.primaryColor)
                            
                            Text("Generating \(viewModel.completedCount)/\(viewModel.batchCount) images...")
                                .font(Theme.appFont(size: 14))
                                .foregroundColor(Theme.textSecondary)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Results Grid
                    if !viewModel.generatedImages.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Generated Images")
                                .font(Theme.appFont(size: 18, weight: .semibold))
                                .foregroundColor(Theme.textPrimary)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                                ForEach(viewModel.generatedImages, id: \.id) { image in
                                    AsyncImage(url: URL(string: "data:image/jpeg;base64,\(Data(image.imageData).base64EncodedString())")) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(height: 150)
                                                .clipped()
                                                .cornerRadius(8)
                                        case .failure(_):
                                            Rectangle()
                                                .fill(Theme.secondaryColor)
                                                .frame(height: 150)
                                                .cornerRadius(8)
                                                .overlay(
                                                    Image(systemName: "photo")
                                                        .foregroundColor(Theme.textSecondary)
                                                )
                                        case .empty:
                                            Rectangle()
                                                .fill(Theme.secondaryColor)
                                                .frame(height: 150)
                                                .cornerRadius(8)
                                                .overlay(
                                                    ProgressView()
                                                )
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .background(Theme.backgroundColor.edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $showingTemplates) {
            PromptTemplatesView { selectedPrompt in
                viewModel.basePrompt = selectedPrompt
                showingTemplates = false
            }
        }
    }
}