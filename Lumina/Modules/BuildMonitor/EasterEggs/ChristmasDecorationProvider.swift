import Foundation
import BuildStatusChecker

struct ChristmasDecorationProvider {
    static let decorations = ["🎄", "🎁", "❄️", "☃️", "🛷", "🌟", "🔔"]
    static var decorationIndex = 0

    static var showChristmasDecorations: Bool {
        let settings = SettingsStore().settings
        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())

        return month == 12 && !settings.disableSeasonalDecorations
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
