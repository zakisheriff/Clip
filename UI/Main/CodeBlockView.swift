import SwiftUI

struct CodeBlockView: View {
    let item: ClipboardItem
    @ObservedObject var engine = ClipboardEngine.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Code Header (Language + Copy)
            HStack {
                Text("Code") // We could improve this with language detection later
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    engine.copyToClipboard(item)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.on.doc")
                        Text("Copy code")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(NSColor.controlBackgroundColor)) // Slightly darker header
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(NSColor.separatorColor)),
                alignment: .bottom
            )
            
            // Code Content
            NativeTextView(text: item.content, font: .monospacedSystemFont(ofSize: 13, weight: .regular))
                .background(Color(NSColor.textBackgroundColor))
        }
        .background(Color(NSColor.textBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
        )
        .padding(20) // Give it some breathing room from the window edges
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
