import SwiftUI

struct PasswordEntryView: View {
    @Binding var isPresented: Bool
    var onPasswordEntered: (Bool) -> Void

    @State private var passwordInput = ""
    @State private var showingError = false
    private var devModePassword: String {
        UserDefaults.standard.string(forKey: "devModePassword") ?? ""
    }
    
    /// Performs a timing-safe comparison of two strings to prevent timing attacks
    private func constantTimeCompare(_ a: String, _ b: String) -> Bool {
        let aData = a.data(using: .utf8) ?? Data()
        let bData = b.data(using: .utf8) ?? Data()
        
        // Ensure both arrays are the same length for constant time comparison
        let maxLength = max(aData.count, bData.count)
        let paddedA = aData + Data(repeating: 0, count: maxLength - aData.count)
        let paddedB = bData + Data(repeating: 0, count: maxLength - bData.count)
        
        var result: UInt8 = 0
        for i in 0..<maxLength {
            result |= paddedA[i] ^ paddedB[i]
        }
        
        return result == 0 && aData.count == bData.count
    }
    
    /// Checks if a valid developer mode password is configured
    private var isPasswordConfigured: Bool {
        let password = UserDefaults.standard.string(forKey: "devModePassword")
        return password?.isEmpty == false
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Developer Mode Password")) {
                    SecureField("Password", text: $passwordInput)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }

                Section {
                    Button("Submit") {
                        // Check if a password is configured
                        guard isPasswordConfigured else {
                            // If no password is configured, deny access and show error
                            passwordInput = ""
                            showingError = true
                            return
                        }
                        
                        // Use timing-safe comparison to prevent timing attacks
                        if constantTimeCompare(passwordInput, devModePassword) {
                            onPasswordEntered(true)
                            isPresented = false
                        } else {
                            passwordInput = ""
                            showingError = true
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        onPasswordEntered(false)
                        isPresented = false
                    }
                }
            }
            .navigationTitle("Enter Password")
            .alert("Authentication Failed", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(isPasswordConfigured ? "Incorrect password. Please try again." : "Developer mode password has not been configured. Please contact your administrator.")
            }
        }
    }
}
