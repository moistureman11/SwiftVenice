import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isLoggedIn = false

    var body: some View {
        if isLoggedIn {
            ContentView()
        } else {
            VStack {
                Text("FayeBlade")
                    .font(.largeTitle)
                    .padding()
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button("Login") {
                    // For now, any username/password will work
                    if !username.isEmpty && !password.isEmpty {
                        isLoggedIn = true
                    }
                }
                .padding()
            }
        }
    }
}
