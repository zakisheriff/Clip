import Foundation
import AppKit
import Combine

class ClipboardEngine: ObservableObject {
    static let shared = ClipboardEngine()
    
    @Published var history: [ClipboardItem] = []
    
    private var lastChangeCount: Int
    private var timer: Timer?
    private let pasteboard = NSPasteboard.general
    
    init() {
        self.lastChangeCount = pasteboard.changeCount
        self.history = Persistence.shared.load()
    }
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkForChanges()
        }
    }
    
    private func checkForChanges() {
        if pasteboard.changeCount != lastChangeCount {
            lastChangeCount = pasteboard.changeCount
            fetchNewContent()
        }
    }
    
    private func fetchNewContent() {
        guard let string = pasteboard.string(forType: .string), !string.isEmpty else { return }
        
        // Ignore duplicates (most recent item)
        if let first = history.first, first.content == string {
            return
        }
        
        // Get source app (best effort)
        // In sandbox, we might not get this easily without Accessibility, 
        // but NSWorkspace.frontmostApplication checks who likely copied it if we poll fast enough 
        // OR we just assume the frontmost app is the source. The timer is 0.5s so it's a guess.
        let frontApp = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        
        let newItem = ClipboardItem(
            content: string,
            type: ClipboardItem.detectType(for: string),
            date: Date(),
            sourceAppBundleID: frontApp,
            characterCount: string.count
        )
        
        DispatchQueue.main.async {
            self.history.insert(newItem, at: 0)
            self.limitHistory()
            Persistence.shared.save(self.history)
        }
    }
    
    private func limitHistory() {
        let max = UserDefaults.standard.integer(forKey: "maxHistoryItems")
        let limit = max > 0 ? max : 50
        if history.count > limit {
            history = Array(history.prefix(limit))
        }
    }
    
    func copyToClipboard(_ item: ClipboardItem) {
        pasteboard.clearContents()
        pasteboard.setString(item.content, forType: .string)
        // Update change count so we don't re-import our own paste
        lastChangeCount = pasteboard.changeCount
    }
    
    func clearHistory() {
        history.removeAll()
        Persistence.shared.clear()
    }
    
    func deleteItem(_ item: ClipboardItem) {
        if let index = history.firstIndex(of: item) {
            history.remove(at: index)
            Persistence.shared.save(history)
        }
    }
}
