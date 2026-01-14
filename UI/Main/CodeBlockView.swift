import SwiftUI

struct CodeBlockView: View {
    let item: ClipboardItem
    @ObservedObject var engine = ClipboardEngine.shared
    @State private var isCopied = false
    
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
                    withAnimation { isCopied = true }
                    
                    // Reset after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation { isCopied = false }
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                        Text(isCopied ? "Copied!" : "Copy code")
                            .frame(minWidth: 60, alignment: .leading) // Fixed width to prevent layout jump
                    }
                    .font(.caption)
                    .foregroundColor(isCopied ? .green : .secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(NSColor.controlBackgroundColor))
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
