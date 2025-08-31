import SwiftUI
import SwiftData

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel

    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(modelContext: modelContext))
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        HStack {
                            if message.role == "user" {
                                Spacer()
                                Text(message.content)
                                    .padding()
                                    .background(Theme.primaryColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .font(Theme.appFont(size: 16))
                            } else {
                                Text(message.content)
                                    .padding()
                                    .background(Theme.secondaryColor)
                                    .foregroundColor(Theme.textPrimary)
                                    .cornerRadius(10)
                                    .font(Theme.appFont(size: 16))
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
            }

            HStack {
                TextField("Enter your message...", text: $viewModel.currentInput)
                    .padding(10)
                    .background(Theme.secondaryColor)
                    .cornerRadius(8)
                    .foregroundColor(Theme.textPrimary)
                    .font(Theme.appFont(size: 16))

                Button("Send") {
                    viewModel.sendMessage()
                }
                .padding()
                .background(Theme.primaryColor)
                .foregroundColor(.white)
                .font(Theme.appFont(size: 16, weight: .bold))
                .cornerRadius(8)
            }
            .padding()
        }
        .background(Theme.backgroundColor.edgesIgnoringSafeArea(.all))
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
    }
}
