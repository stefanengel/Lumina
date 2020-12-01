import SwiftUI
import BuildStatusChecker

class BuildViewModel: ObservableObject {
    let title: String
    let triggeredAt: String
    var subtitle: String?
    let backgroundColor: Color
    let url: String
    let subBuilds: [BuildRepresentation]

    @Published var isRunning: Bool = false

    var hasSubBuilds: Bool {
        !subBuilds.isEmpty
    }

    init(from build: BuildRepresentation) {
        title = build.wrapped.branch

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale.current
        triggeredAt = dateFormatter.string(from: build.triggeredAt)

        switch build.status {
            case .success: backgroundColor = Colors.emerald
            case .failed(let error):
                backgroundColor = Colors.alizarin
                if let error = error {
                    subtitle = "\(error)\n"
                }
            case .running:
                backgroundColor = Colors.belizeHole
                isRunning = true
            case .aborted(let reason):
                backgroundColor = Colors.carrot
                if let reason = reason {
                    subtitle = "\(reason)\n"
                }
            default: backgroundColor = Colors.hoki
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
        subBuilds = build.subBuilds
    }

    func openInBrowser() {
        let buildUrl = URL(string: url)!
        NSWorkspace.shared.open(buildUrl)
    }
}
