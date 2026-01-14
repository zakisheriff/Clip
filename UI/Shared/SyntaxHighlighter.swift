import AppKit

struct SyntaxHighlighter {
    static func highlight(code: String, font: NSFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: code, attributes: [
            .font: font,
            .foregroundColor: NSColor.labelColor
        ])
        
        let wholeRange = NSRange(location: 0, length: code.utf16.count)
        
        // Definitions for colors (Zenburn/VSCode-ish dark mode friendly, but readable in light)
        let keywordColor = NSColor.systemPurple
        let stringColor = NSColor.systemRed
        let commentColor = NSColor.systemGray
        let numberColor = NSColor.systemBlue
        let typeColor = NSColor.systemTeal
        
        // 1. Comments (// ... or # ...)
        // We do matches safely to avoid overlapping issues later if we were strict, 
        // but for simple highlighting, applying regexes in order of "least priority" to "most priority" helps,
        // or just recognizing that Regex matching is flat. 
        // Actually, we should match comments first? No, simplest Regex approach:
        
        // Keywords
        let keywords = [
            "func", "var", "let", "if", "else", "return", "struct", "class", "enum", "import",
            "def", "print", "import", "from", "class", "return", "if", "elif", "else", "while", "for", "in",
            "public", "private", "static", "void", "int", "float", "double", "string", "bool", "true", "false", "nil", "null"
        ]
        let keywordPattern = "\\b(\(keywords.joined(separator: "|")))\\b"
        applyPattern(keywordPattern, to: attributedString, color: keywordColor)
        
        // Types (Capitalized words, rough heuristic)
        let typePattern = "\\b[A-Z][a-zA-Z0-9_]*\\b"
        applyPattern(typePattern, to: attributedString, color: typeColor)
        
        // Numbers
        let numberPattern = "\\b\\d+(\\.\\d+)?\\b"
        applyPattern(numberPattern, to: attributedString, color: numberColor)
        
        // Strings ("..." or '...')
        let stringPattern = "\"[^\"]*\"|'[^']*'"
        applyPattern(stringPattern, to: attributedString, color: stringColor)
        
        // Comments (// ... or # ...)
        // Note: This overrides previous colors if matched, which is correct (keywords inside comments are comments)
        let commentPattern = "//.*|#.*"
        applyPattern(commentPattern, to: attributedString, color: commentColor)
        
        return attributedString
    }
    
    private static func applyPattern(_ pattern: String, to string: NSMutableAttributedString, color: NSColor) {
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: string.string.utf16.count)
        
        regex?.enumerateMatches(in: string.string, options: [], range: range) { match, _, _ in
            if let matchRange = match?.range {
                string.addAttribute(.foregroundColor, value: color, range: matchRange)
            }
        }
    }
}
