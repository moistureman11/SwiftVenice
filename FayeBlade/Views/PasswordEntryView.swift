import SwiftUI

struct PasswordEntryView: View {
    @Binding var isPresented: Bool
    var onPasswordEntered: (Bool) -> Void

    @State private var passwordInput = ""
    @State private var showingError = false
    private var devModePassword: String {
        UserDefaults.standard.string(forKey: "devModePassword") ?? ""
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
                        if passwordInput == devModePassword {
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
            .alert("Incorrect Password", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}
