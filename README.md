# FayeBlade

FayeBlade is a local-first Swift application for iOS that provides a secure and private environment for AI-powered chat and image generation. Built by **Faye Håkansdotter** and powered by **[Venice.ai](https://venice.ai)**.

## Features

### Core Features
- **Local-First:** All data is stored exclusively on your device. Nothing is saved online.
- **Secure Login:** The app features a login screen to protect your content.
- **AI Chat:** Engage in conversations using advanced AI models from Venice.ai
- **Image Generation:** Create high-quality images from text prompts
- **Image Enhancement:** Upscale and enhance generated images

### Developer Features
- **Developer Mode:** A password-protected developer mode allows for advanced configuration and content filter management. The password can be configured in the app settings.
- **CSAM Filter Testing:** When dev mode is enabled, safe mode is disabled for testing new LORA models and content filters.

### New Innovative Features
- **🎨 Prompt Templates:** Access a curated library of professional prompt templates across categories like Photography, Art, Sci-Fi, Fantasy, and more. Create and save your own custom templates.
- **⚡ Batch Generation:** Generate multiple variations of an image simultaneously with customizable settings including random seeds and style variations.

## Project Structure

The project is built with SwiftUI and follows a standard MVVM (Model-View-ViewModel) architecture.

- `FayeBlade/`: The main application module.
  - `FayeBladeApp.swift`: The entry point of the application.
  - `Views/`: Contains all the SwiftUI views.
    - `LoginView.swift`: The main login screen.
    - `ContentView.swift`: The main content screen after login.
    - `SettingsView.swift`: The settings screen with the dev mode toggle.
    - `ChatView.swift`: AI chat interface.
    - `ImageGenerationView.swift`: Single image generation interface.
    - `BatchGenerationView.swift`: Batch image generation interface.
    - `PromptTemplatesView.swift`: Prompt template library and management.
  - `ViewModels/`: Contains the view models that manage the state and logic for the views.
  - `Models/`: Contains the data models for the application.
  - `Stores/`: Contains the settings and state management.
  - `Helpers/`: Utility classes including Keychain management.

## API Integration

FayeBlade integrates with Venice.ai's API to provide:
- Chat completions using venice-uncensored model
- High-quality image generation with customizable parameters
- Image upscaling and enhancement capabilities

The app automatically manages safe mode settings based on developer mode status:
- **Normal Mode**: Safe mode enabled for content filtering
- **Developer Mode**: Safe mode disabled for CSAM filter testing and LORA model experimentation

## Security

- All user credentials are stored securely in the iOS Keychain
- API keys are managed through environment variables
- Local data persistence using SwiftData ensures privacy
- Developer mode is password-protected.

## Built With

- **SwiftUI** - Modern iOS app development framework
- **SwiftData** - Local data persistence
- **Venice.ai API** - AI chat and image generation
- **iOS Keychain** - Secure credential storage

---

*FayeBlade is built by Faye Håkansdotter and powered by Venice.ai*
