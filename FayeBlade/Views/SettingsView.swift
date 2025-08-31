import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsStore
    @State private var showingPasswordSheet = false
    @State private var showingLogoutConfirmation = false

    let aspectRatios = ["1:1", "3:4", "4:3", "16:9"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Toggle("Use Dark Mode", isOn: $settings.isDarkMode)
                }

                Section(header: Text("API")) {
                    TextField("API Key", text: $settings.apiKey)
                }

                Section(header: Text("Image Settings")) {

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

                Section(header: Text("Developer")) {
                    Toggle("Dev Mode", isOn: devModeBinding)

                    if settings.isDevModeEnabled {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("CSAM Filter Disabled")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }

                        Text("Dev mode is active for testing LORA models and content filters. Safe mode is disabled.")
                            .font(.caption2)
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                
                Section {
                    Button("Logout", role: .destructive) {
                        showingLogoutConfirmation = true
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPasswordSheet) {
                PasswordEntryView(isPresented: $showingPasswordSheet) { success in
                    self.settings.isDevModeEnabled = success
                }
            }
            .alert("Are you sure you want to logout?", isPresented: $showingLogoutConfirmation) {
                Button("Logout", role: .destructive) {
                    settings.apiKey = ""
                }
                Button("Cancel", role: .cancel) {
                    showingLogoutConfirmation = false
                }
            }
        }
    }

    private var devModeBinding: Binding<Bool> {
        Binding<Bool>(
            get: { self.settings.isDevModeEnabled },
            set: { newValue in
                if newValue {
                    showingPasswordSheet = true
                } else {
                    self.settings.isDevModeEnabled = false
                }
            }
        )
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(SettingsStore())
    }
}
