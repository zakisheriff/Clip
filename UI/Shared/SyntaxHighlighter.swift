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
        
        // ORDERING: Apply General -> Specific (Last one wins)
        // 1. Keywords (Generic)
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
        let patternString = keywords.joined(separator: "|")
        let keywordPattern = "\\b(\(patternString))\\b"
        applyPattern(keywordPattern, to: attributedString, color: keywordColor)
        
        // 2. Numbers
        let numberPattern = "\\b\\d+(\\.\\d+)?\\b"
        applyPattern(numberPattern, to: attributedString, color: numberColor)
        
        // 3. Types / Capitalized Words
        let typePattern = "\\b[A-Z][a-zA-Z0-9_]*\\b"
        applyPattern(typePattern, to: attributedString, color: typeColor)
        
        // 4. Decorators
        let decoratorPattern = "@\\w+"
        applyPattern(decoratorPattern, to: attributedString, color: attributeColor)
        
        // 5. HTML Tags
        let htmlTagPattern = "</?[a-zA-Z0-9]+"
        applyPattern(htmlTagPattern, to: attributedString, color: numberColor)
        let htmlClosePattern = ">"
        applyPattern(htmlClosePattern, to: attributedString, color: numberColor)
        
        // 6. Strings (Overrides previous if overlap)
        let stringPattern = "\"[^\"]*\"|'[^']*'"
        applyPattern(stringPattern, to: attributedString, color: stringColor)
        
        // 7. Comments (Overrides all)
        let commentPattern = "//.*|#.*|/\\*[\\s\\S]*?\\*/|<!--[\\s\\S]*?-->"
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
