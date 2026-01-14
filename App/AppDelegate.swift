import SwiftUI
import AppKit
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    private var cancellables = Set<AnyCancellable>()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 1. Setup Menu Bar Item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "clipboard", accessibilityDescription: "Clip")
            button.action = #selector(togglePopover(_:))
            button.target = self
            // Initial placeholder to verify tooltip works at all
            button.toolTip = "Clip: Loading..."
        }
        
        // 2. Setup Popover
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 400)
        popover.behavior = .transient // Closes on click-away
        popover.animates = false // Disable animation for snappy "native" feel
        
        // Inject dependencies
        popover.contentViewController = NSHostingController(rootView: MenuBarView(closeAction: { [weak self] in
            self?.closePopover(sender: nil)
        }))
        
        self.popover = popover
        
        // 3. Start Engine & Setup Tooltip Observer
        let engine = ClipboardEngine.shared
        engine.startMonitoring()
        
        // Subscribe to history changes for tooltip
        engine.$history
            .receive(on: DispatchQueue.main)
            .sink { [weak self] history in
                self?.updateTooltip(history.first)
            }
            .store(in: &cancellables)
            
        // Trigger immediate update
        updateTooltip(engine.history.first)
    }
    
    private func updateTooltip(_ item: ClipboardItem?) {
        guard let button = statusItem?.button else { return }
        
        if let item = item {
            // Simplify text processing for stability
            let raw = item.content
            let prefix = raw.prefix(60)
            let cleaned = prefix.replacingOccurrences(of: "\n", with: " ")
            let tooltipText = "Current: \(cleaned)..."
            
            button.toolTip = tooltipText
            // print("Set tooltip to: \(tooltipText)") 
        } else {
            button.toolTip = "Clip: Empty"
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if statusItem?.button != nil {
            if let popover = popover {
                if popover.isShown {
                    closePopover(sender: sender)
                } else {
                    showPopover(sender: sender)
                }
            }
        }
    }
    
    func showPopover(sender: AnyObject?) {
        if let button = statusItem?.button {
            // Activate app so popover can take focus if needed
            NSApp.activate(ignoringOtherApps: true)
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
    
    func closePopover(sender: AnyObject?) {
        popover?.performClose(sender)
    }
    
    // Handle URL scheme opening
    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
             if url.absoluteString.contains("open") {
                 NSApp.activate(ignoringOtherApps: true)
             }
        }
    }
}
