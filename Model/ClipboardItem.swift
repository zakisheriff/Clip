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
        // Simple heuristic
        if let url = URL(string: string), url.scheme != nil, url.host != nil {
            return .url
        }
        
        // Very basic code detection (look for braces, func, var, common keywords)
        let codeIndicators = ["func ", "var ", "let ", "import ", "{", "}", "class ", "struct ", "def ", "return ", ";"]
        let count = codeIndicators.filter { string.contains($0) }.count
        if count >= 3 {
            return .code
        }
        
        return .text
    }
}
