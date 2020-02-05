import BuildStatusChecker
import SwiftUI

class BuildMonitorViewModel: ObservableObject {
    @Published var development: Build?
    @Published var master: Build?
    @Published var release: Build?
    @Published var hotfix: Build?
    @Published var feature: [Build] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = true

    private let model: BuildMonitorModel?

    init(model: BuildMonitorModel) {
        self.model = model
        model.register(observer: self)
    }

    deinit {
        model?.unregister(observer: self)
    }

    // Used for preview
    init(development: Build, master: Build, release: Build, hotfix: Build, feature: [Build]) {
        self.development = development
        self.master = master
        self.release = release
        self.hotfix = hotfix
        self.feature = feature
        model = nil
    }
}


// MARK: - Converting errors into messages
extension BuildMonitorViewModel {
    func errorMessage(from error: BuildFetcherError) -> String {
        switch error {
        case .incompleteProviderConfiguration: return "Incomplete configuration"
        case .noNetworkConnection: return "No network connection"
        case .requestFailed(let message): return "Request failed: \(message)"
        }
    }
}

// MARK - Model observer
extension BuildMonitorViewModel: ModelObserver {
    func startedLoading() {
        DispatchQueue.main.async {
            self.isLoading = true
        }
    }

    func stoppedLoading() {
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }

    func updateFailed(error: BuildFetcherError) {
        DispatchQueue.main.async {
            self.errorMessage = self.errorMessage(from: error)
        }
    }

    func update(builds: Builds) {
        DispatchQueue.main.async {
            self.development = builds.development
            self.master = builds.master
            self.release = builds.latestRelease
            self.hotfix = builds.latestHotfix
            self.feature = builds.sortedFeatureBuilds
        }
    }
}
