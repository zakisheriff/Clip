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
        
        statusItem?.button?.image = NSImage(systemSymbolName: "clipboard", accessibilityDescription: "Clip")
        statusItem?.button?.action = #selector(togglePopover(_:))
        statusItem?.button?.target = self
        
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
        
        engine.$history
            .receive(on: DispatchQueue.main)
            .sink { [weak self] history in
                if let first = history.first {
                    let content = first.content.trimmingCharacters(in: .whitespacesAndNewlines)
                    let preview = content.count > 50 ? String(content.prefix(50)) + "..." : content
                    self?.statusItem?.button?.toolTip = "Current: \(preview)"
                } else {
                    self?.statusItem?.button?.toolTip = "Clip: Empty"
                }
            }
            .store(in: &cancellables)
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
            // Activate app so popover can take focus if needed, though transient usually handles fine.
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
                 // The WindowGroup in ClipApp handles the window, we just need to make sure we activate
                 NSApp.activate(ignoringOtherApps: true)
             }
        }
    }
}
