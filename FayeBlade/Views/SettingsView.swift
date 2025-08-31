import SwiftUI

struct SettingsView: View {
    @State private var isDevModeEnabled = false
    @State private var showingPasswordAlert = false
    @State private var passwordInput = ""
    private let devModePassword = "262854"

    var body: some View {
        Form {
            Section(header: Text("Developer")) {
                Toggle("Dev Mode", isOn: $isDevModeEnabled)
                    .onChange(of: isDevModeEnabled) { value in
                        if value {
                            // If user tries to enable, show password prompt
                            showingPasswordAlert = true
                        }
                    }
            }
        }
        .navigationTitle("Settings")
        .alert("Enter Password", isPresented: $showingPasswordAlert) {
            SecureField("Password", text: $passwordInput)
            Button("OK") {
                if passwordInput == devModePassword {
                    // Correct password, keep dev mode enabled
                } else {
                    // Incorrect password, disable dev mode
                    isDevModeEnabled = false
                }
                passwordInput = ""
            }
            Button("Cancel", role: .cancel) {
                isDevModeEnabled = false
                passwordInput = ""
            }
        }
    }
}
