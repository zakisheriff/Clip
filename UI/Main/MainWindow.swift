import SwiftUI

struct MainWindow: View {
    @ObservedObject var engine = ClipboardEngine.shared
    @State private var selection: ClipboardItem.ID?
    @State private var filter: ClipboardType? // If nil, show all
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $filter) {
                NavigationLink(value: nil as ClipboardType?) {
                    Label("All Items", systemImage: "tray.full")
                }
                
                Section("Types") {
                    NavigationLink(value: ClipboardType.text) {
                        Label("Text", systemImage: "text.alignleft")
                    }
                    NavigationLink(value: ClipboardType.url) {
                        Label("Links", systemImage: "link")
                    }
                    NavigationLink(value: ClipboardType.code) {
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
            .navigationTitle(filter?.rawValue.capitalized ?? "All Items")
            .navigationSplitViewColumnWidth(min: 250, ideal: 300)
            .onChange(of: filteredHistory) { history in
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
            if let selectedId = selection, 
               let item = engine.history.first(where: { $0.id == selectedId }) {
                DetailView(item: item)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.3))
                    Text("Select an item to view details")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 900, minHeight: 600) // Larger default window
    }
    
    var filteredHistory: [ClipboardItem] {
        if let type = filter {
            return engine.history.filter { $0.type == type }
        }
        return engine.history
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
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                VStack(alignment: .leading) {
                    Text(item.type.rawValue.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    Text("\(item.characterCount) characters")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    engine.copyToClipboard(item)
                }) {
                    Label("Copy Full Content", systemImage: "doc.on.doc")
                }
                .controlSize(.large)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .border(width: 1, edges: [.bottom], color: Color(NSColor.separatorColor))
            
            // Content Area - Improved for reading and selecting
            ScrollView {
                VStack(alignment: .leading) {
                    Text(item.content)
                        .font(.system(.body, design: .monospaced))
                        .kerning(0.5) // Slight letter spacing for readability
                        .lineSpacing(4)
                        .padding(20)
                        .textSelection(.enabled) // Critical for user request
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(NSColor.textBackgroundColor))
                }
            }
            .background(Color(NSColor.textBackgroundColor))
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
