import Foundation
import AppKit

enum ClipboardType: String, Codable, CaseIterable {
    case text
    case url
    case code
    case image // Reserved for future
}

struct ClipboardItem: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    let content: String
    let type: ClipboardType
    let date: Date
    let sourceAppBundleID: String?
    let characterCount: Int
    
    // Hashable conformance for SwiftUI Lists
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Helper to determine type
    static func detectType(for string: String) -> ClipboardType {
        // 1. Robust Link Detection using NSDataDetector
        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) {
            let range = NSRange(location: 0, length: string.utf16.count)
            let matches = detector.matches(in: string, options: [], range: range)
            
            // If the *entire* string is roughly a URL, or the first match covers most of it
            if let match = matches.first {
                if match.range.location == 0 && match.range.length == string.utf16.count {
                     return .url
                }
                // Allow "loose" URLs if they are just the URL
                if string.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("http") {
                    return .url
                }
            }
        }
        
        // 2. Code Detection Heuristics
        // Look for syntax characters common in C-style, Swift, Python, JS, etc.
        let codeSignals = ["func ", "var ", "let ", "const ", "import ", "class ", "struct ", "def ", "return", "print(", "console.log", "=>", "UI", "NS", ";", "{", "}", "()", "//", "#include"]
        let signalCount = codeSignals.filter { string.contains($0) }.count
        
        // If it has enough keywords OR structured braces/semi-colons
        if signalCount >= 2 || (string.contains("{") && string.contains("}")) || string.contains("    ") { // indent detection
            return .code
        }
        
        return .text
    }
}
