import Foundation

struct ChristmasDecorationProvider {
    static let decorations = ["🎄", "🎁", "❄️", "☃️", "🛷"]
    static var decorationIndex = 0

    static var showChristmasDecorations: Bool {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())

        return month == 12
    }

    static func decorate(text: String) -> String {
        let decoration = decorations[decorationIndex]

        decorationIndex += 1

        if decorationIndex >= decorations.count {
            decorationIndex = 0
        }

        return "\(decoration) \(text) \(decoration)"
    }
}
