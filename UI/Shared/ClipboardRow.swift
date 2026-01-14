import SwiftUI

struct ClipboardRow: View {
    let item: ClipboardItem
    var onCopy: (ClipboardItem) -> Void
    @State private var isHovering = false
    @State private var isCopied = false
    
    var body: some View {
        ZStack {
            if isCopied {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Copied!")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            } else {
                HStack(spacing: 12) {
                    // Icon based on type
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.secondary.opacity(0.1))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: iconName)
                            .foregroundColor(.accentColor)
                            .font(.system(size: 14, weight: .medium))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.content.trimmingCharacters(in: .whitespacesAndNewlines))
                            .font(.system(size: 13, weight: .regular)) // SF Pro
                            .lineLimit(1)
                            .foregroundColor(.primary)
                        
                        Text(timeString(date: item.date))
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if isHovering {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(isHovering || isCopied ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(6)
        .onHover { hover in
            withAnimation(.easeInOut(duration: 0.1)) {
                isHovering = hover
            }
        }
        .onTapGesture {
            guard !isCopied else { return }
            withAnimation {
                isCopied = true
            }
            // Delay closing/copying to show feedback
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                onCopy(item)
                // Optionally reset state if view persists
                isCopied = false
            }
        }
    }
    
    var iconName: String {
        switch item.type {
        case .url: return "link"
        case .code: return "chevron.left.forwardslash.chevron.right"
        default: return "text.alignleft"
        }
    }
    
    func timeString(date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
