import SwiftUI
import BuildStatusChecker

class BuildViewModel: ObservableObject {
    let build: BuildRepresentation
    let title: String
    let triggeredAt: String
    let url: String
    let subBuilds: [BuildRepresentation]
    var decoratedTitle: String {
        if ChristmasDecorationProvider.showChristmasDecorations {
            return ChristmasDecorationProvider.decorate(text: title)
        }

        return title
    }

    private var buildAPI = BuildAPIClientFactory.createBuildAPI()

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

    var backgroundColor: Color {
        switch build.status {
            case .success: return Colors.emerald
            case .failed(_): return Colors.alizarin
            case .running: return Colors.belizeHole
            case .aborted(_): return Colors.carrot
            default: return Colors.hoki
        }
    }

    init(from build: BuildRepresentation) {
        self.build = build
        title = build.wrapped.branch

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale.current
        triggeredAt = dateFormatter.string(from: build.triggeredAt)

        if case .running = build.status {
            isRunning = true
        }

        url = build.url
        subBuilds = build.subBuilds
    }

    func openInBrowser() {
        let buildUrl = URL(string: url)!
        NSWorkspace.shared.open(buildUrl)
    }

    func copyBuildNumber() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString("#\(build.buildNumber)", forType: .string)
    }

    func triggerBuild() {

    }

    func cancelBuild() {
        buildAPI.cancelBuild(buildId: build.id)
    }
}
