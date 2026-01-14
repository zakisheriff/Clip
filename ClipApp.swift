//
//  ClipApp.swift
//  Clip
//
//  Created by Zaki Sheriff on 2026-01-14.
//

import SwiftUI

@main
struct ClipApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // The main window. We can close it by default or only show when requested.
        // SwiftUI 'WindowGroup' creates a window. To have it hidden by default is tricky in pure SwiftUI 
        // without `Settings` scene only. But we want a "Main Window" that is summonable.
        // A common pattern for "Menu Bar Apps" is to not have a WindowGroup, but open one programmatically 
        // or use `Window` scene which requires macOS 13+.
        
        WindowGroup("Clipboard", id: "mainWindow") {
            MainWindow()
        }
        // This is simplified. In a real 'Menu Bar First' app, we might remove WindowGroup 
        // and only open NSWindow manually in AppDelegate to prevent it showing on launch.
        // However, for this requirement "No window shown unless user opens it":
        // We will add logic in AppDelegate/Info.plist to suppress launch.
        // But pure SwiftUI App lifecycle often forces a window.
        // TRICK: We can use Settings scene for settings, and WindowGroup for main, 
        // but we'll use `commands` to replace the "New Window" action.
        
        Settings {
            SettingsView()
        }
    }
}
