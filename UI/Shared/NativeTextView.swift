import SwiftUI
import AppKit

struct NativeTextView: NSViewRepresentable {
    var text: String
    var attributedText: NSAttributedString? = nil // Optional rich text support
    var font: NSFont = .systemFont(ofSize: NSFont.systemFontSize)
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        
        let textView = NSTextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.drawsBackground = false
        textView.font = font
        textView.textColor = .labelColor
        
        // Link Detection
        textView.isAutomaticLinkDetectionEnabled = true
        
        if let attributedText = attributedText {
            textView.textStorage?.setAttributedString(attributedText)
        } else {
            textView.string = text
        }
        
        // Layout: Fill width, grow height
        textView.autoresizingMask = [.width]
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        
        // Container settings
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(width: scrollView.contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        
        // Padding
        textView.textContainerInset = NSSize(width: 20, height: 20)
        
        scrollView.documentView = textView
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        if let attributedText = attributedText {
             if textView.textStorage?.string != attributedText.string {
                 textView.textStorage?.setAttributedString(attributedText)
             }
        } else {
            if textView.string != text {
                textView.string = text
            }
        }
    }
}
