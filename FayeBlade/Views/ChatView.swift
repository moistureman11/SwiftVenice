import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(viewModel.messages) { message in
                        HStack {
                            if message.role == "user" {
                                Spacer()
                                Text(message.content)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            } else {
                                Text(message.content)
                                    .padding()
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }

            HStack {
                TextField("Enter your message...", text: $viewModel.currentInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading)

                Button("Send") {
                    viewModel.sendMessage()
                }
                .padding(.trailing)
            }
            .padding(.bottom)
        }
        .navigationTitle("Chat")
    }
}
