import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsStore

    // State for the dev mode password alert
    @State private var showingPasswordAlert = false
    @State private var passwordInput = ""
    private let devModePassword = "262854"

    let aspectRatios = ["1:1", "3:4", "4:3", "16:9"]

    var body: some View {
        Form {
            Section(header: Text("Image Settings").foregroundColor(Theme.textSecondary)) {

                Text("Number of images")
                Picker("Number of images", selection: $settings.numberOfImages) {
                    ForEach(1...8, id: \.self) { number in
                        Text("\(number)").tag(number)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                Toggle("Photoreal", isOn: $settings.isPhotoreal)
                Toggle("Alchemy", isOn: $settings.isAlchemy)
                Toggle("Public images", isOn: $settings.isPublic)

                Text("Aspect Ratio")
                Picker("Aspect Ratio", selection: $settings.aspectRatio) {
                    ForEach(aspectRatios, id: \.self) { ratio in
                        Text(ratio).tag(ratio)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                VStack(alignment: .leading) {
                    Text("Guidance: \(Int(settings.guidance))")
                    Slider(value: $settings.guidance, in: 1...20, step: 1)
                }

                VStack(alignment: .leading) {
                    Text("Variants: \(Int(settings.variants))")
                    Slider(value: $settings.variants, in: 1...10, step: 1)
                }
            }

            Section(header: Text("Developer").foregroundColor(Theme.textSecondary)) {
                Toggle("Dev Mode", isOn: $settings.isDevModeEnabled)
                    .onChange(of: settings.isDevModeEnabled) { value in
                        if value {
                            showingPasswordAlert = true
                        }
                    }
            }
        }
        .foregroundColor(Theme.textPrimary)
        .alert("Enter Password", isPresented: $showingPasswordAlert) {
            SecureField("Password", text: $passwordInput)
            Button("OK") {
                if passwordInput == devModePassword {
                    // Correct password
                } else {
                    settings.isDevModeEnabled = false
                }
                passwordInput = ""
            }
            Button("Cancel", role: .cancel) {
                settings.isDevModeEnabled = false
                passwordInput = ""
            }
        }
    }
}
