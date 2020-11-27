import BuildStatusChecker
import SwiftUI

class BuildMonitorViewModel: ObservableObject {
    @Published var development: [Build] = []
    @Published var master: [Build] = []
    @Published var release: [Build] = []
    @Published var hotfix: [Build] = []
    @Published var feature: [Build] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = true

    @Published var search: String = "" {
        didSet {
            updateFilteredBuilds()
        }
    }
    @Published var filteredBuilds: [Build] = []

    private let model: BuildMonitorModel?

    init(model: BuildMonitorModel) {
        self.model = model
        model.register(observer: self)
    }

    deinit {
        model?.unregister(observer: self)
    }

    private func updateFilteredBuilds() {
        if search.isEmpty {
            filteredBuilds = allBuilds
        }
        else {
            filteredBuilds = allBuilds.filter{ $0.branch.contains(search) }
        }
    }

    // Used for preview
    init(development: [Build], master: [Build], release: [Build], hotfix: [Build], feature: [Build]) {
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
            self.development = builds.sortedDevelopBuilds
            self.master = builds.sortedMasterBuilds
            self.release = builds.sortedLatestReleaseBuilds
            self.hotfix = builds.sortedLatestHotfixBuilds
            self.feature = builds.sortedFeatureBuilds

            self.updateFilteredBuilds()
        }
    }
}

// MARK: - Putting together the filtered build list
extension BuildMonitorViewModel {
    private var allBuilds: [Build] {
        var allBuilds = [Build]()

        allBuilds.append(contentsOf: development)
        allBuilds.append(contentsOf: master)
        allBuilds.append(contentsOf: release)
        allBuilds.append(contentsOf: hotfix)
        allBuilds.append(contentsOf: feature)

        return allBuilds
    }
}
