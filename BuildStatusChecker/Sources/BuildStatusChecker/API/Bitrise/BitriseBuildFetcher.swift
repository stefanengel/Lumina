import Foundation
import Combine
import os.log

public class BitriseBuildFetcher {
    let settings: SettingsStoreProtocol = SettingsStore()

    public init() {
    }
    
    var cancellable: Cancellable?
}

// MARK: - BuildFetcher
extension BitriseBuildFetcher: BuildFetcher {
    public func getRecentBuilds(completion: @escaping (Result<Builds, BuildFetcherError>) -> Void) {
        let config = BitriseConfiguration()

        guard config.isComplete else {
            completion(.failure(BuildFetcherError.incompleteProviderConfiguration))
            return
        }

        var existingBranches: BitriseBranches?

        cancellable = BitriseAPI.branches(config: config)
        .flatMap { branches -> AnyPublisher<BitriseBuilds, Error> in
            existingBranches = branches
            return BitriseAPI.builds(config: config)
        }
        .flatMap { builds -> AnyPublisher<BitriseBuilds, Error> in
            return self.complementInformationForBranch(withPrefix: self.settings.read(setting: .releaseBranchPrefix), existingBranches: existingBranches!, builds: builds, config: config)
        }
        .flatMap { builds -> AnyPublisher<BitriseBuilds, Error> in
            return self.complementInformationForBranch(withPrefix: self.settings.read(setting: .hotfixBranchPrefix), existingBranches: existingBranches!, builds: builds, config: config)
        }
        .flatMap { builds -> AnyPublisher<BitriseBuilds, Error> in
            return self.complementBuildInformationIfMissing(for: self.settings.read(setting: .developBranchName), existingBranches: existingBranches!, builds: builds, config: config)
        }
        .flatMap { builds -> AnyPublisher<BitriseBuilds, Error> in
            return self.complementBuildInformationIfMissing(for: self.settings.read(setting: .masterBranchName), existingBranches: existingBranches!, builds: builds, config: config)
        }
        .mapError() { error -> BuildFetcherError in
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
            let builds = Builds()

            os_log("Received %{PUBLIC}d builds", log: OSLog.buildFetcher, type: .debug, bitriseBuilds.data.count)

            if config.groupByBuildNumber {
                var buildGroups = [String: GroupedBuild]()
                for bitriseBuild in bitriseBuilds.data {
                    // grouping commitHash is not enough since rolling builds will have the same hash, we have to group by build number
                    if let existingGroup = buildGroups["\(bitriseBuild.parentBuildNumber ?? bitriseBuild.buildNumber)"] {
                        existingGroup.append(build: bitriseBuild.asBuildRepresentation)
                    }
                    else {
                        let newGroup = GroupedBuild(builds: [bitriseBuild.asBuildRepresentation])
                        buildGroups["\(bitriseBuild.parentBuildNumber ?? bitriseBuild.buildNumber)"] = newGroup
                    }
                }

                for (_, group) in buildGroups {
                    builds.add(build: BuildRepresentation(wrapped: group))
                }
            }
            else {
                for bitriseBuild in bitriseBuilds.data {
                    builds.add(build: bitriseBuild.asBuildRepresentation)
                }
            }

            completion(.success(builds))
        })
    }
}

// MARK: - Helpers for branches that have a prefix
extension BitriseBuildFetcher {
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
extension BitriseBuildFetcher {
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
extension BitriseBuildFetcher {
    private func complementLatestBuild(for branch: Branch, existingBuilds builds: BitriseBuilds, config: BitriseConfiguration) -> AnyPublisher<BitriseBuilds, Error> {
        return BitriseAPI.builds(config: config, forBranch: branch, limit: 1)
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
