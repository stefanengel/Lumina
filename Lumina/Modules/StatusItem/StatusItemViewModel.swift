import Foundation
import AppKit
import BuildStatusChecker

class StatusItemViewModel {
    static let successfulBuildAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: NSColor.systemGreen,
        .strokeColor: NSColor.black,
        .strokeWidth: -3.0
    ]
    static let failedBuildAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: NSColor.systemRed,
        .strokeColor: NSColor.black,
        .strokeWidth: -3.0
    ]
    static let abortedBuildAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: NSColor.systemOrange,
        .strokeColor: NSColor.black,
        .strokeWidth: -3.0
    ]
    static let runningBuildAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: NSColor.systemBlue,
        .strokeColor: NSColor.black,
        .strokeWidth: -3.0
    ]
    static let unknownBuildAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: NSColor.systemGray,
        .strokeColor: NSColor.black,
        .strokeWidth: -3.0
    ]

    var development: Build?
    var master: Build?
    var release: Build?
    var hotfix: Build?
    var feature: [Build] = []

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
    func build(for branch: Branch) -> Build? {
        if development?.branch == branch { return development }
        if master?.branch == branch { return master }
        if release?.branch == branch { return release }
        if hotfix?.branch == branch { return hotfix }

        for featureBuild in feature {
            if featureBuild.branch == branch { return featureBuild }
        }

        return nil
    }

    func url(for branch: Branch) -> URL? {
        guard let build = build(for: branch) else {
            return nil
        }

        return URL(string: build.url)
    }
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

    func updateFailed(error: BuildFetcherError) {
    }

    func update(builds: Builds) {
        development = builds.development
        master = builds.master
        release = builds.latestRelease
        hotfix = builds.latestHotfix
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
