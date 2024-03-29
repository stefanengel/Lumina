import BuildStatusChecker
import SwiftUI

class BuildMonitorViewModel: ObservableObject {
    @Published var development: [BuildRepresentation] = []
    @Published var master: [BuildRepresentation] = []
    @Published var release: [BuildRepresentation] = []
    @Published var hotfix: [BuildRepresentation] = []
    @Published var feature: [BuildRepresentation] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = true
    @Published var buildQueueInfo: BuildQueueInfo?

    @Published var search: String = "" {
        didSet {
            updateFilteredBuilds()
        }
    }
    @Published var filteredBuilds: [BuildRepresentation] = []

    let model: BuildMonitorModel
    let buildAPIClient: BuildAPIClient

    init(model: BuildMonitorModel, buildAPIClient: BuildAPIClient) {
        self.model = model
        self.buildAPIClient = buildAPIClient
        model.register(observer: self)
    }

    deinit {
        model.unregister(observer: self)
    }

    private func updateFilteredBuilds() {
        DispatchQueue.main.async {
            withAnimation {
                if self.search.isEmpty {
                    self.filteredBuilds = self.allBuilds
                }
                else {
                    self.filteredBuilds = self.allBuilds.filter{ $0.branch.contains(self.search) }
                }
            }
        }
    }

    // Used for preview
    #warning("Why is this in production code?")
    init(development: [BuildRepresentation], master: [BuildRepresentation], release: [BuildRepresentation], hotfix: [BuildRepresentation], feature: [BuildRepresentation]) {
        self.development = development
        self.master = master
        self.release = release
        self.hotfix = hotfix
        self.feature = feature
        model = BuildMonitorModel(buildAPIClient: BuildAPIClientMock.create())
        buildAPIClient = BuildAPIClientMock.create()
    }
}


// MARK: - Converting errors into messages
extension BuildMonitorViewModel {
    func errorMessage(from error: BuildAPIClientError) -> String {
        switch error {
        case .incompleteProviderConfiguration: return "Incomplete configuration"
        case .noNetworkConnection: return "No network connection"
        case .requestFailed(let message): return "Request failed: \(message)"
        case .organizationNotFound: return "Organization not found!"
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

    func updateFailed(error: BuildAPIClientError) {
        DispatchQueue.main.async {
            self.errorMessage = self.errorMessage(from: error)
        }
    }

    func update(builds: Builds, buildQueueInfo: BuildQueueInfo) {
        DispatchQueue.main.async {
            self.errorMessage = nil
            
            self.development = builds.sortedDevelopBuilds
            self.master = builds.sortedMasterBuilds
            self.release = builds.sortedLatestReleaseBuilds
            self.hotfix = builds.sortedLatestHotfixBuilds
            self.feature = builds.sortedFeatureBuilds

            self.buildQueueInfo = buildQueueInfo

            self.updateFilteredBuilds()
        }
    }
}

// MARK: - Putting together the filtered build list
extension BuildMonitorViewModel {
    private var allBuilds: [BuildRepresentation] {
        var allBuilds = [BuildRepresentation]()

        allBuilds.append(contentsOf: development)
        allBuilds.append(contentsOf: master)
        allBuilds.append(contentsOf: release)
        allBuilds.append(contentsOf: hotfix)
        allBuilds.append(contentsOf: feature)

        return allBuilds
    }
}
