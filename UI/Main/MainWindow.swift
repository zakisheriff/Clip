import SwiftUI

struct MainWindow: View {
    enum SidebarFilter: Hashable {
        case all
        case type(ClipboardType)
    }

    @ObservedObject var engine = ClipboardEngine.shared
    @State private var selection: ClipboardItem.ID?
    @State private var sidebarFilter: SidebarFilter? = .all // Default to .all
    // Removed columnVisibility state to prevent system from forcing the toggle button
    
    var body: some View {
        NavigationSplitView {
            List(selection: $sidebarFilter) {
                // FIXED: Use a concrete enum case for "All Items" so it mimics a selectable item.
                // Reverted icon to 'doc.on.clipboard' to match user preference.
                NavigationLink(value: SidebarFilter.all) {
                    Label("All Items", systemImage: "doc.on.clipboard")
                }
                
                Section("Types") {
                    NavigationLink(value: SidebarFilter.type(.text)) {
                        Label("Text", systemImage: "text.alignleft")
                    }
                    NavigationLink(value: SidebarFilter.type(.url)) {
                        Label("Links", systemImage: "link")
                    }
                    NavigationLink(value: SidebarFilter.type(.code)) {
                        Label("Code", systemImage: "chevron.left.forwardslash.chevron.right")
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("Library")
            .navigationSplitViewColumnWidth(min: 150, ideal: 200)
            
        } content: {
            List(selection: $selection) {
                ForEach(filteredHistory) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.content)
                            .lineLimit(3)
                            .font(.system(size: 13))
                            .foregroundColor(.primary)
                        
                        HStack {
                            Text(item.type.rawValue.capitalized)
                                .font(.system(size: 10, weight: .semibold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(4)
                            
                            Text(timeString(date: item.date))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                    }
                    .padding(.vertical, 6)
                    .tag(item.id)
                    .contextMenu {
                        Button("Copy") {
                            engine.copyToClipboard(item)
                        }
                        Divider()
                        Button("Delete", role: .destructive) {
                            engine.deleteItem(item)
                            if selection == item.id { selection = nil }
                        }
                    }
                }
            }
            .listStyle(InsetListStyle())
            .listStyle(InsetListStyle())
            .navigationTitle(currentTitle)
            // Fix: Equalize ideal width with Detail view for 50/50 split. 
            .navigationSplitViewColumnWidth(min: 300, ideal: 400)
            .onChange(of: filteredHistory) { _, history in
                if selection == nil, let first = history.first {
                    selection = first.id
                }
            }
            .onAppear {
                if selection == nil, let first = filteredHistory.first {
                    selection = first.id
                }
            }
            
        } detail: {
            ZStack {
                if let selectedId = selection, 
                   let item = engine.history.first(where: { $0.id == selectedId }) {
                    DetailView(item: item)
                        .toolbar(removing: .sidebarToggle) // MOVED HERE to force removal
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.on.clipboard")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary.opacity(0.3))
                        Text("Select an item to view details")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .toolbar(removing: .sidebarToggle) // Apply here too
                }
            }
            .navigationSplitViewColumnWidth(min: 300, ideal: 400)
            // Fix: Equalize ideal width with List view (350).
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 1000, minHeight: 600)
        // Force remove the system sidebar toggle if it persists unwantedly
        .toolbar(removing: .sidebarToggle)
    }
    
    var currentTitle: String {
        switch sidebarFilter {
        case .type(let type): return type.rawValue.capitalized
        case .all, .none: return "All Items"
        }
    }

    var filteredHistory: [ClipboardItem] {
        switch sidebarFilter {
        case .type(let type):
            return engine.history.filter { $0.type == type }
        case .all, .none:
            return engine.history
        }
    }
    
    func timeString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct DetailView: View {
    let item: ClipboardItem
    @ObservedObject var engine = ClipboardEngine.shared
    @State private var isCopied = false
    
    var body: some View {
        Group {
            if item.type == .code {
                CodeBlockView(item: item)
            } else {
                // Standard Notes-style for Text/Links
                VStack(spacing: 0) {
                    // Notes-style Metadata Header (Subtle, centered or leading)
                    HStack {
                        Text("\(item.type.rawValue.uppercased()) • \(item.characterCount) chars")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                        
                        Spacer()
                        
                        // Inline Copy Button with Feedback
                        Button(action: {
                            engine.copyToClipboard(item)
                            withAnimation { isCopied = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation { isCopied = false }
                            }
                        }) {
                            Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                                .font(.system(size: 14)) // Ensure consistent size
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.borderless)
                        .controlSize(.small)
                        .help("Copy content")
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)
                    .background(Color(NSColor.textBackgroundColor))
                    
                    // Content Area - Native Text View taking remaining space
                    NativeTextView(text: item.content, font: .systemFont(ofSize: 13))
                        .background(Color(NSColor.textBackgroundColor))
                }
            }
        }
    }
}

// Helper for border
extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}

struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var x: CGFloat {
                switch edge {
                case .top, .bottom, .leading: return rect.minX
                case .trailing: return rect.maxX - width
                }
            }

            var y: CGFloat {
                switch edge {
                case .top, .leading, .trailing: return rect.minY
                case .bottom: return rect.maxY - width
                }
            }

            var w: CGFloat {
                switch edge {
                case .top, .bottom: return rect.width
                case .leading, .trailing: return width
                }
            }

            var h: CGFloat {
                switch edge {
                case .top, .bottom: return width
                case .leading, .trailing: return rect.height
                }
            }
            path.addRect(CGRect(x: x, y: y, width: w, height: h))
        }
        return path
    }
}
