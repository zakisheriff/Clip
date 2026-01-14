import Foundation

class Persistence {
    static let shared = Persistence()
    private let key = "savedClipboardHistory"
    
    func save(_ items: [ClipboardItem]) {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func load() -> [ClipboardItem] {
        if let data = UserDefaults.standard.data(forKey: key),
           let items = try? JSONDecoder().decode([ClipboardItem].self, from: data) {
            return items
        }
        return []
    }
    
    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
