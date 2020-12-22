import SwiftUI
import BuildStatusChecker

class SubBuildViewModel: ObservableObject {
    let build: BuildRepresentation
    let title: String
    let url: String

    private var buildAPI = BuildAPIClientFactory.createBuildAPI()

    @Published var backgroundColor: Color
    @Published var isRunning: Bool = false

    init(from build: BuildRepresentation) {
        self.build = build
        title = build.groupItemDescription ?? build.branch
        url = build.url

        switch build.status {
            case .success: backgroundColor = Colors.emerald
            case .failed(_):
                backgroundColor = Colors.alizarin
            case .running:
                backgroundColor = Colors.belizeHole
                isRunning = true
            case .aborted(_):
                backgroundColor = Colors.carrot
            default: backgroundColor = Colors.hoki
        }
    }

    func openInBrowser() {
        let buildUrl = URL(string: url)!
        NSWorkspace.shared.open(buildUrl)
    }

    func cancelBuild() {
        buildAPI.cancelBuild(buildId: build.id)
    }

    func triggerBuild() {
        buildAPI.cancelBuild(buildId: build.id)
    }
}
