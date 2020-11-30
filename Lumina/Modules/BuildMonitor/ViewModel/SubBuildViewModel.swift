import SwiftUI
import BuildStatusChecker

class SubBuildViewModel: ObservableObject {
    let title: String
    let url: String

    @Published var backgroundColor: Color
    @Published var isRunning: Bool = false

    init(from build: BuildRepresentation) {
        title = build.groupItemDescription ?? build.branch
        url = build.url

        switch build.status {
            case .success: backgroundColor = .green
            case .failed(_):
                backgroundColor = .red
            case .running:
                backgroundColor = .blue
                isRunning = true
            case .aborted(_):
                backgroundColor = .orange
            default: backgroundColor = .gray
        }
    }

    func openInBrowser() {
        let buildUrl = URL(string: url)!
        NSWorkspace.shared.open(buildUrl)
    }
}
