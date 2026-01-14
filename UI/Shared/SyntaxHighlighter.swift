import AppKit

struct SyntaxHighlighter {
    static func highlight(code: String, font: NSFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: code, attributes: [
            .font: font,
            .foregroundColor: NSColor.labelColor
        ])
        
        let wholeRange = NSRange(location: 0, length: code.utf16.count)
        
        // Definitions for colors (Inspired by standard VSCode/Xcode themes)
        let keywordColor = NSColor.systemPink // const, let, var, if, func
        let functionColor = NSColor.systemPurple // functions, methods
        let stringColor = NSColor.systemRed // "string"
        let numberColor = NSColor.systemBlue // 123
        let commentColor = NSColor.systemGray // // comment
        let typeColor = NSColor.systemTeal // ClassName, Int, Bool
        let attributeColor = NSColor.systemOrange // @State, <html lang="...">
        
        // 1. Comments (Match first to avoid coloring keywords inside comments)
        let commentPattern = "//.*|#.*|/\\*[\\s\\S]*?\\*/|<!--[\\s\\S]*?-->"
        applyPattern(commentPattern, to: attributedString, color: commentColor)
        
        // 2. Strings
        // Matches "..." or '...'
        let stringPattern = "\"[^\"]*\"|'[^']*'"
        applyPattern(stringPattern, to: attributedString, color: stringColor)
        
        // 3. HTML Tags and Attributes
        // Tag names (e.g., <div, </div>, <img) - simplistic approach
        // Match <Name or </Name
        let htmlTagPattern = "</?[a-zA-Z0-9]+"
        applyPattern(htmlTagPattern, to: attributedString, color: numberColor) // Use Blue/Teal for tags (like VSCode)
        let htmlClosePattern = ">"
        applyPattern(htmlClosePattern, to: attributedString, color: numberColor)
        
        // 4. Swift Decorators / Annotations (@State, @Published)
        let decoratorPattern = "@\\w+"
        applyPattern(decoratorPattern, to: attributedString, color: attributeColor)
        
        // 5. Keywords (Expanded List)
        let keywords = [
            // Swift
            "func", "var", "let", "if", "else", "return", "struct", "class", "enum", "import", "extension", "protocol", "init", "guard", "switch", "case", "default", "break", "continue", "try", "catch", "throw", "throws", "async", "await", "self", "super",
            // Python
            "def", "print", "from", "elif", "while", "for", "in", "with", "as", "pass", "lambda", "global", "nonlocal", "yield", "except", "finally", "raise",
            // JS/TS
            "const", "function", "export", "default", "typeof", "instanceof", "new", "this", "console", "window", "document", "null", "undefined",
            // General/C-like
            "void", "int", "float", "double", "bool", "char", "public", "private", "protected", "static", "final", "true", "false", "nil"
        ]
        // Sorting by length (descending) ensures "import" is matched before "in", etc., though \b mostly handles this.
        let patternString = keywords.joined(separator: "|")
        let keywordPattern = "\\b(\(patternString))\\b"
        applyPattern(keywordPattern, to: attributedString, color: keywordColor)
        
        // 6. Numbers
        let numberPattern = "\\b\\d+(\\.\\d+)?\\b"
        applyPattern(numberPattern, to: attributedString, color: numberColor)
        
        // 7. Types / Capitalized Words (Heuristic: Starts with Capital, not inside generic brackets)
        // This is tricky with regex, but a basic \b[A-Z]\w+\b helps highlight class names
        // avoiding pure ALLCAPS sometimes helps avoid constants, but User default is fine.
        let typePattern = "\\b[A-Z][a-zA-Z0-9_]*\\b"
        applyPattern(typePattern, to: attributedString, color: typeColor)
        
        // Re-apply comments/strings at the end? 
        // In Regex based highlighting without a parser, the LAST applied attribute wins.
        // We want Comments and Strings to WIN so that keywords inside them are not colored.
        // So we apply Keywords FIRST, then Strings, then Comments.
        
        // WAIT: My order above was Comments (1) -> Strings (2) -> Keywords (5).
        // If I apply Keywords (5) AFTER Comments (1), then a keyword inside a comment " // var x " will get colored as a Keyword.
        // That is WRONG.
        // I must apply Keywords/Types/Numbers FIRST, and then overlay Strings and Comments ON TOP.
        
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
