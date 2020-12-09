import Foundation
import AppKit
import BuildStatusChecker

class StatusItemViewModel {
    private static let strokeWidth: CGFloat = -1.0

    static let successfulBuildAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: NSColor.systemGreen,
        .strokeColor: NSColor.black,
        .strokeWidth: strokeWidth
    ]
    static let failedBuildAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: NSColor.systemRed,
        .strokeColor: NSColor.black,
        .strokeWidth: strokeWidth
    ]
    static let abortedBuildAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: NSColor.systemOrange,
        .strokeColor: NSColor.black,
        .strokeWidth: strokeWidth
    ]
    static let runningBuildAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: NSColor.systemBlue,
        .strokeColor: NSColor.black,
        .strokeWidth: strokeWidth
    ]
    static let unknownBuildAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: NSColor.systemGray,
        .strokeColor: NSColor.black,
        .strokeWidth: strokeWidth
    ]

    var development: [BuildRepresentation] = []
    var master: [BuildRepresentation] = []
    var release: [BuildRepresentation] = []
    var hotfix: [BuildRepresentation] = []
    var feature: [BuildRepresentation] = []

    let model: BuildMonitorModel
    let title = "Lumina"

    var viewDelegate: StatusItemViewDelegate?

    init(model: BuildMonitorModel) {
        self.model = model
        model.register(observer: self)
    }

    deinit {
        model.unregister(observer: self)
    }
}

// MARK: - Helpers used by the StatusItem
extension StatusItemViewModel {
//    func builds(for branch: Branch) -> [Build] {
//        var results = [Build]()
//
//        results.append(contentsOf: development.filter{ $0.branch == branch })
//
//        if development?.branch == branch { return development }
//        if master?.branch == branch { return master }
//        if release?.branch == branch { return release }
//        if hotfix?.branch == branch { return hotfix }
//
//        for featureBuild in feature {
//            if featureBuild.branch == branch { return featureBuild }
//        }
//
//        return nil
//    }

//    func url(for branch: Branch) -> URL? {
//        guard let build = build(for: branch) else {
//            return nil
//        }
//
//        return URL(string: build.url)
//    }
}

// MARK: - Helpers for color
extension StatusItemViewModel {
    func attributes(for status: BuildStatus) -> [NSAttributedString.Key: Any] {
        switch status {
            case .success: return StatusItemViewModel.successfulBuildAttributes
            case .failed: return StatusItemViewModel.failedBuildAttributes
            case .aborted: return StatusItemViewModel.abortedBuildAttributes
            case .running: return StatusItemViewModel.runningBuildAttributes
            case .unknown: return StatusItemViewModel.unknownBuildAttributes
        }
    }
}

// MARK - Model observer
extension StatusItemViewModel: ModelObserver {
    func startedLoading() {
    }

    func stoppedLoading() {
    }

    func updateFailed(error: BuildAPIClientError) {
    }

    func update(builds: Builds) {
        development = builds.sortedDevelopBuilds
        master = builds.sortedMasterBuilds
        release = builds.sortedLatestReleaseBuilds
        hotfix = builds.sortedLatestHotfixBuilds
        feature = builds.sortedFeatureBuilds

        DispatchQueue.main.async {
            self.viewDelegate?.updateMenu()
        }
    }
}

// MARK: - Opening build in browser
extension StatusItemViewModel {
    func openInBrowser(build: Build) {
        guard let buildUrl = URL(string: build.url) else {
            return
        }

        NSWorkspace.shared.open(buildUrl)
    }
}
