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
                if let error = error {
                    subtitle = "\(error)\n"
                }
            case .running:
                backgroundColor = .blue
                isRunning = true
            case .aborted(let reason):
                backgroundColor = .orange
                if let reason = reason {
                    subtitle = "\(reason)\n"
                }
            default: backgroundColor = .gray
        }

        if let info = build.info {
            if var subtitle = subtitle {
                subtitle.append(info)
            }
            else {
                subtitle = info
            }
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
