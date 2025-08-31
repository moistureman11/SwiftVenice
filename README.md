# FayeBlade

FayeBlade is a local-first Swift application for iOS that provides a secure and private environment for chat and image management.

## Features

*   **Local-First:** All data is stored exclusively on your device. Nothing is saved online.
*   **Secure Login:** The app features a login screen to protect your content.
*   **Developer Mode:** A password-protected developer mode allows for advanced configuration and content filter management.

## Project Structure

The project is built with SwiftUI and follows a standard MVVM (Model-View-ViewModel) architecture.

*   `FayeBlade/`: The main application module.
    *   `FayeBladeApp.swift`: The entry point of the application.
    *   `Views/`: Contains all the SwiftUI views.
        *   `LoginView.swift`: The main login screen.
        *   `ContentView.swift`: The main content screen after login.
        *   `SettingsView.swift`: The settings screen with the dev mode toggle.
    *   `ViewModels/`: Contains the view models that manage the state and logic for the views.
    *   `Models/`: Contains the data models for the application.
