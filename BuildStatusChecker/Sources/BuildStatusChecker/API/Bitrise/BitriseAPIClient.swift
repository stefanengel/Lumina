import Foundation
import Combine
import os.log

public class BitriseAPIClient {
    let settings: Settings
    let config: BitriseConfiguration

    public init(settings: Settings, config: BitriseConfiguration) {
        self.settings = settings
        self.config = config
    }
    
    var cancelSet: Set<AnyCancellable> = []
}

// MARK: - BuildFetcher
extension BitriseAPIClient: BuildAPIClient {
    public func triggerBuild(buildParams: GenericBuildParams) {
        BitriseAPI.triggerBuild(config: config, buildParams: buildParams)
            .sink(receiveCompletion: { compl in
                switch compl {
                    case .finished: os_log("triggerBuild finished", log: OSLog.buildFetcher, type: .debug)
                    case .failure(let error):
                        os_log("triggerBuild finished with error: %{PUBLIC}@", log: OSLog.buildFetcher, type: .error, error.localizedDescription)
                }
            }, receiveValue: {

            })
            .store(in: &cancelSet)

    }

    public func cancelBuild(buildId: String) {
        BitriseAPI.cancelBuild(config: config, buildSlug: buildId, reason: "Aborted via Lumina")
            .sink(receiveCompletion: { compl in
                switch compl {
                    case .finished: os_log("cancelBuild finished", log: OSLog.buildFetcher, type: .debug)
                    case .failure(let error):
                        os_log("cancelBuild finished with error: %{PUBLIC}@", log: OSLog.buildFetcher, type: .error, error.localizedDescription)
                }
            }, receiveValue: {

            })
            .store(in: &cancelSet)
    }

    public func getRecentBuilds(completion: @escaping (Result<Builds, BuildAPIClientError>) -> Void) {
        guard config.isComplete else {
            completion(.failure(BuildAPIClientError.incompleteProviderConfiguration))
            return
        }

        var existingBranches: BitriseBranches?

        BitriseAPI.branches(config: config)
        .flatMap { branches -> AnyPublisher<BitriseBuilds, Error> in
            existingBranches = branches
            return BitriseAPI.builds(settings: self.settings, config: self.config)
        }
        .flatMap { builds -> AnyPublisher<BitriseBuilds, Error> in
            return self.complementInformationForBranch(withPrefix: self.settings.releaseBranchPrefix, existingBranches: existingBranches!, builds: builds, config: self.config)
        }
        .flatMap { builds -> AnyPublisher<BitriseBuilds, Error> in
            return self.complementInformationForBranch(withPrefix: self.settings.hotfixBranchPrefix, existingBranches: existingBranches!, builds: builds, config: self.config)
        }
        .flatMap { builds -> AnyPublisher<BitriseBuilds, Error> in
            return self.complementBuildInformationIfMissing(for: self.settings.developBranchName, existingBranches: existingBranches!, builds: builds, config: self.config)
        }
        .flatMap { builds -> AnyPublisher<BitriseBuilds, Error> in
            return self.complementBuildInformationIfMissing(for: self.settings.masterBranchName, existingBranches: existingBranches!, builds: builds, config: self.config)
        }
        .mapError() { error -> BuildAPIClientError in
            if let urlError = error as? URLError, urlError.code.rawValue == -1009 {
                return .noNetworkConnection
            }
            return .requestFailed(message: error.localizedDescription)
        }
        .sink(receiveCompletion: { compl in
            switch compl {
                case .finished: os_log("getRecentBuilds finished", log: OSLog.buildFetcher, type: .debug)
                case .failure(let error):
                    os_log("getRecentBuilds finished with error: %{PUBLIC}@", log: OSLog.buildFetcher, type: .error, error.localizedDescription)
                    completion(.failure(error))
            }
        }, receiveValue: { (bitriseBuilds) in
            let builds = Builds(settings: self.settings)

            os_log("Received %{PUBLIC}d builds", log: OSLog.buildFetcher, type: .debug, bitriseBuilds.data.count)

            if self.settings.groupByBuildNumber {
                var buildGroups = [String: GroupedBuild]()
                for bitriseBuild in bitriseBuilds.data {
                    // grouping commitHash is not enough since rolling builds will have the same hash, we have to group by build number
                    if let existingGroup = buildGroups[bitriseBuild.groupId] {
                        existingGroup.append(build: bitriseBuild.asBuildRepresentation(settings: self.settings))
                    }
                    else {
                        let newGroup = GroupedBuild(builds: [bitriseBuild.asBuildRepresentation(settings: self.settings)])
                        buildGroups[bitriseBuild.groupId] = newGroup
                    }
                }

                for (_, group) in buildGroups {
                    builds.add(build: BuildRepresentation(wrapped: group, settings: self.settings))
                }
            }
            else {
                for bitriseBuild in bitriseBuilds.data {
                    builds.add(build: bitriseBuild.asBuildRepresentation(settings: self.settings))
                }
            }

            completion(.success(builds))
        })
        .store(in: &cancelSet)
    }

    public func getBuildQueueInfo(completion: @escaping (Result<BuildQueueInfo, BuildAPIClientError>) -> Void) {
        guard config.isComplete, !config.orgSlug.isEmpty else {
            completion(.failure(BuildAPIClientError.incompleteProviderConfiguration))
            return
        }

        var organization: Organization?
        var buildsOnHold = 0
        var buildsRunning = 0

        BitriseAPI.organization(config: config)
        .flatMap { orga -> AnyPublisher<Int, Error> in
            organization = orga
            return BitriseAPI.numberOfbuilds(config: self.config, onHold: false)
        }
        .flatMap { runningBuildCount -> AnyPublisher<Int, Error> in
            buildsRunning = runningBuildCount
            return BitriseAPI.numberOfbuilds(config: self.config, onHold: true)
        }
        .flatMap { onHoldBuildCount -> AnyPublisher<BuildQueueInfo, Error> in
            buildsOnHold = onHoldBuildCount
            guard let organization = organization else {
                return Fail(error: BuildAPIClientError.organizationNotFound).eraseToAnyPublisher()
            }
            return Just(BuildQueueInfo(totalSlots: organization.concurrencyCount, runningBuilds: buildsRunning, queuedBuilds: buildsOnHold))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        .mapError() { error -> BuildAPIClientError in
            if let urlError = error as? URLError, urlError.code.rawValue == -1009 {
                return .noNetworkConnection
            }
            return .requestFailed(message: error.localizedDescription)
        }
        .sink(receiveCompletion: { compl in
            switch compl {
                case .finished: os_log("getBuildQueueInfo finished", log: OSLog.buildFetcher, type: .debug)
                case .failure(let error):
                    os_log("getBuildQueueInfo finished with error: %{PUBLIC}@", log: OSLog.buildFetcher, type: .error, error.localizedDescription)
                    completion(.failure(error))
            }
        }, receiveValue: { buildQueueInfo in
            os_log("Queue: %{PUBLIC}@", log: OSLog.buildFetcher, type: .debug, buildQueueInfo.description)
            completion(.success(buildQueueInfo))
        })
        .store(in: &cancelSet)
    }
}

// MARK: - Helpers for branches that have a prefix
extension BitriseAPIClient {
    private func complementInformationForBranch(withPrefix prefix: String, existingBranches: BitriseBranches, builds: BitriseBuilds, config: BitriseConfiguration) -> AnyPublisher<BitriseBuilds, Error> {
        if let latestPrefixedBranch = existingBranches.findLatestBranch(withPrefix: prefix) {
            os_log("Latest branch prefixed with %{PUBLIC}@ found: %{PUBLIC}@", log: OSLog.buildFetcher, type: .debug, prefix, latestPrefixedBranch)
            return self.complementBuildInformationIfMissing(for: latestPrefixedBranch, existingBranches: existingBranches, builds: builds, config: config)
        }

        // If the branch is not found at all then we simply ignore it for now
        return Future<BitriseBuilds, Error> { promise in
            os_log("Branch prefixed with %{PUBLIC}@ not found", log: OSLog.buildFetcher, type: .debug, prefix)
            promise(.success(builds))
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Complementing incomplete build information
extension BitriseAPIClient {
    private func complementBuildInformationIfMissing(for branch: Branch, existingBranches: BitriseBranches, builds: BitriseBuilds, config: BitriseConfiguration) -> AnyPublisher<BitriseBuilds, Error> {
        if !builds.contains(branch: branch) {
            os_log("Branch named %{PUBLIC}@ not found in builds, requesting extra information...", log: OSLog.buildFetcher, type: .debug, branch)
            return self.complementLatestBuild(for: branch, existingBuilds: builds, config: config)
        }

        return Future<BitriseBuilds, Error> { promise in
            os_log("Branch named %{PUBLIC}@ found in builds", log: OSLog.buildFetcher, type: .debug, branch)
            promise(.success(builds))
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Explicitly loading latest build
extension BitriseAPIClient {
    private func complementLatestBuild(for branch: Branch, existingBuilds builds: BitriseBuilds, config: BitriseConfiguration) -> AnyPublisher<BitriseBuilds, Error> {
        return BitriseAPI.builds(settings: self.settings, config: config, forBranch: branch, limit: 1)
        .flatMap { additionalBuilds -> Future<BitriseBuilds, Error> in
            var complementedBuilds = BitriseBuilds()
            complementedBuilds.data.append(contentsOf: builds.data)
            complementedBuilds.data.append(contentsOf: additionalBuilds.data)

            if additionalBuilds.data.isEmpty {
                os_log("No additional build information found for branch %{PUBLIC}@", log: OSLog.buildFetcher, type: .debug, branch)
            }
            else {
                os_log("Received additional build information for branch %{PUBLIC}@", log: OSLog.buildFetcher, type: .debug, branch)
            }

            return Future<BitriseBuilds, Error> { promise in
                promise(.success(complementedBuilds))
            }
        }
        .eraseToAnyPublisher()
    }
}
