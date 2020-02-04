import Cocoa
import SwiftUI
import BuildStatusChecker

struct BuildViewModel {
    var title: String
    var triggeredAt: String
    var subtitle: String?
    var backgroundColor: Color
    var url: String
    var isRunning: Bool = false

    init(from build: Build) {
        title = build.branch

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale.current
        triggeredAt = dateFormatter.string(from: build.triggeredAt)

        switch build.status {
            case .success: backgroundColor = .green
            case .failed(let error):
                backgroundColor = .red
                subtitle = error
            case .running:
                backgroundColor = .blue
                isRunning = true
            case .aborted(let reason):
                backgroundColor = .orange
                subtitle = reason
            default: backgroundColor = .gray
        }

        url = build.url
    }

    init(title: String, triggeredAt: String, subtitle: String? = nil, backgroundColor: Color, url: String) {
        self.title = title
        self.triggeredAt = triggeredAt
        self.subtitle = subtitle
        self.backgroundColor = backgroundColor
        self.url = url
    }

    func openInBrowser() {
        let buildUrl = URL(string: url)!
        NSWorkspace.shared.open(buildUrl)
    }
}
