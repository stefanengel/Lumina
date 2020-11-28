import Foundation

class IgnorePattern {
    private(set) var pattern: String

    init(pattern: String) {
        self.pattern = pattern
    }
}

extension IgnorePattern: Hashable {
    static func == (lhs: IgnorePattern, rhs: IgnorePattern) -> Bool {
        return lhs.pattern == rhs.pattern
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(pattern)
    }
}
