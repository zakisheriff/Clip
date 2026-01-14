import SwiftUI

struct SettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("maxHistoryItems") private var maxHistoryItems = 50
    @ObservedObject var engine = ClipboardEngine.shared
    
    var body: some View {
        TabView {
            Form {
                Section {
                    Toggle("Launch at login", isOn: $launchAtLogin)
                        .disabled(true) 
                        // Note: LaunchAtLogin requires SMAppService or specific setup not fully scriptable 
                        // in simple file gen without target config. We leave UI here.
                    
                    Picker("History Size", selection: $maxHistoryItems) {
                        Text("25 items").tag(25)
                        Text("50 items").tag(50)
                        Text("100 items").tag(100)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        engine.clearHistory()
                    } label: {
                        Text("Clear Clipboard History")
                    }
                }
            }
            .padding()
            .tabItem {
                Label("General", systemImage: "gear")
            }
        }
        .frame(width: 350, height: 200)
    }
}
