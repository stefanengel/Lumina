import SwiftUI
import BuildStatusChecker

class BuildViewModel: ObservableObject {
    let build: BuildRepresentation
    let title: String
    let triggeredAt: String
    let backgroundColor: Color
    let url: String
    let subBuilds: [BuildRepresentation]
    var decoratedTitle: String {
        if ChristmasDecorationProvider.showChristmasDecorations {
            return ChristmasDecorationProvider.decorate(text: title)
        }

        return title
    }

    @Published var isRunning: Bool = false

    var hasSubBuilds: Bool {
        !subBuilds.isEmpty
    }

    var subTitle: String {
        var result = ""

        switch build.status {
            case .failed(let error):
                if let error = error {
                    result.append("\(error)\n")
                }
            case .aborted(let reason):
                if let reason = reason {
                    result.append("\(reason)\n")
                }
            default: break
        }

        if let info = build.info {
            result.append("\(info)\n")
        }

        result.append("#\(build.buildNumber)")

        return result
    }

    init(from build: BuildRepresentation) {
        self.build = build
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
            case .running:
                backgroundColor = Colors.belizeHole
                isRunning = true
            case .aborted(let reason):
                backgroundColor = Colors.carrot
            default: backgroundColor = Colors.hoki
        }

        url = build.url
        subBuilds = build.subBuilds
    }

    func openInBrowser() {
        let buildUrl = URL(string: url)!
        NSWorkspace.shared.open(buildUrl)
    }
}
