import SwiftUI

struct MenuBarView: View {
    @ObservedObject var engine = ClipboardEngine.shared
    @State private var searchText = ""
    @Environment(\.colorScheme) var colorScheme
    
    // Callback to close popover
    var closeAction: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header / Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search clipboard...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 13))
            }
            .padding(10)
            .background(colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
            .cornerRadius(8)
            .padding(12)
            
            Divider()
            
            // List
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredHistory) { item in
                        ClipboardRow(item: item)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                copyAndClose(item)
                            }
                            .padding(.horizontal, 8)
                    }
                    
                    if filteredHistory.isEmpty {
                        Text("No items found")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .padding(.top, 20)
                    }
                }
                .padding(.vertical, 8)
            }
            .frame(height: 350)
            
            Divider()
            
            // Footer
            HStack {
                Button("Open Clip") {
                    openMainWindow()
                    closeAction()
                }
                .buttonStyle(.plain)
                .font(.system(size: 12, weight: .medium))
                
                Spacer()
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            }
            .padding(12)
            .background(VisualEffectView(material: .sidebar, blendingMode: .behindWindow))
        }
        .frame(width: 320)
        .background(VisualEffectView(material: .popover, blendingMode: .behindWindow))
    }
    
    var filteredHistory: [ClipboardItem] {
        if searchText.isEmpty {
            return engine.history
        } else {
            return engine.history.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    func copyAndClose(_ item: ClipboardItem) {
        engine.copyToClipboard(item)
        closeAction()
    }
    
    func openMainWindow() {
        // Force activation immediately
        NSApp.activate(ignoringOtherApps: true)
        
        // Use URL scheme to trigger WindowGroup if needed (requires Info.plist registration)
        // If not registered, activation above handles focus if window is already open.
        if let url = URL(string: "clipapp://open") {
            NSWorkspace.shared.open(url)
        }
    }
}

// Transparent background helper
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
