import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @State private var isSigningUp = false
    @State private var authMessage = ""

    var body: some View {
        if isLoggedIn {
            ContentView()
        } else {
            VStack(spacing: 20) {
                Text("FayeBlade")
                    .font(Theme.appFont(size: 48, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                if !authMessage.isEmpty {
                    Text(authMessage)
                        .foregroundColor(.red)
                        .font(Theme.appFont(size: 14))
                }

                if isSigningUp {
                    Button("Sign Up") {
                        handleSignUp()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                } else {
                    Button("Login") {
                        handleLogin()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }

                Button(isSigningUp ? "Already have an account? Login" : "Don't have an account? Sign Up") {
                    isSigningUp.toggle()
                    authMessage = ""
                }
                .font(Theme.appFont(size: 14))
                .foregroundColor(Theme.accentColor)

            }
            .padding(40)
            .background(Theme.backgroundColor)
            .edgesIgnoringSafeArea(.all)
        }
    }

    private func handleLogin() {
        if let savedPassword = KeychainHelper.getPassword(forUsername: username) {
            if password == savedPassword {
                isLoggedIn = true
            } else {
                authMessage = "Invalid password."
            }
        } else {
            authMessage = "No account found for this username."
        }
    }

    private func handleSignUp() {
        if username.isEmpty || password.isEmpty {
            authMessage = "Username and password cannot be empty."
            return
        }

        if KeychainHelper.save(password: password, forUsername: username) {
            authMessage = "Account created successfully! Please log in."
            isSigningUp = false
        } else {
            authMessage = "Failed to create account."
        }
    }
}

// A custom button style for the primary buttons
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.appFont(size: 18, weight: .bold))
            .padding()
            .frame(maxWidth: .infinity)
            .background(Theme.primaryColor)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}
