import Foundation
import Combine

class SettingsStore: ObservableObject {
    @Published var numberOfImages: Int = 1
    @Published var isPhotoreal: Bool = false
    @Published var isAlchemy: Bool = true
    @Published var isPublic: Bool = false
    @Published var aspectRatio: String = "1:1"
    @Published var guidance: Double = 7.0
    @Published var variants: Double = 3.0

    // Add other settings from the UI
    @Published var model: String = "hidream" // Default model
    @Published var style: String = "Cinematic" // Default style

    // Dev mode settings
    @Published var isDevModeEnabled: Bool = false
}
