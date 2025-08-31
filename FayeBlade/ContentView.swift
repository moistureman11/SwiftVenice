import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Hello, FayeBlade!")
                    .font(.largeTitle)
                    .padding()

                NavigationLink(destination: ChatView()) {
                    Text("Go to Chat")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                NavigationLink(destination: ImageGenerationView()) {
                    Text("Generate Image")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                NavigationLink(destination: SettingsView()) {
                    Text("Go to Settings")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}
