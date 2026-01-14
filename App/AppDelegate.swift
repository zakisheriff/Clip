import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 1. Setup Menu Bar Item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "clipboard", accessibilityDescription: "Clipboard")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
        
        // 2. Setup Popover
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 400)
        popover.behavior = .transient // Closes on click-away
        popover.animates = true
        
        // Inject dependencies
        popover.contentViewController = NSHostingController(rootView: MenuBarView(closeAction: { [weak self] in
            self?.closePopover(sender: nil)
        }))
        
        self.popover = popover
        
        // 3. Start Engine
        ClipboardEngine.shared.startMonitoring()
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusItem?.button {
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
