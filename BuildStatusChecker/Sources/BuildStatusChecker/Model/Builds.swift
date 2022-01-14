import os.log

public class Builds {
    public var development: [String: BuildRepresentation] = [:]
    public var master: [String: BuildRepresentation] = [:]
    public var latestRelease: [String: BuildRepresentation] = [:]
    public var latestHotfix: [String: BuildRepresentation] = [:]
    public var feature: [String: BuildRepresentation] = [:]
    public let settings: Settings

    public lazy var filter: BuildFilter = BuildFilter(settings: settings)

    public init(settings: Settings) {
        self.settings = settings
    }

    public func add(build: BuildRepresentation) {
        if build.isDevelopBranch {
            if let existingDevelopBuild = development[groupId(for: build)], existingDevelopBuild.wrapped.triggeredAt > build.wrapped.triggeredAt {
                return
            }

            if !filter.shouldHide(build: build) {
                development[groupId(for: build)] = build
            }
        }
        else if build.isMasterBranch {
            if let existingMasterBuild = master[groupId(for: build)], existingMasterBuild.triggeredAt > build.triggeredAt {
                return
            }

            if !filter.shouldHide(build: build) {
                master[groupId(for: build)] = build
            }
        }
        else if build.isReleaseBranch {
            if let existingReleaseBuild = latestRelease[groupId(for: build)], existingReleaseBuild.triggeredAt > build.triggeredAt {
                return
            }

            if !filter.shouldHide(build: build) {
                latestRelease[groupId(for: build)] = build
            }
        }
        else if build.isHotfixBranch {
            if let existingHotfixBuild = latestHotfix[groupId(for: build)], existingHotfixBuild.triggeredAt > build.triggeredAt {
                return
            }

            if !filter.shouldHide(build: build) {
                latestHotfix[groupId(for: build)] = build
            }
        }
        else if build.isFeatureBranch {
            if let existingFeatureBuild = feature[groupId(for: build)], existingFeatureBuild.triggeredAt > build.triggeredAt {
                return
            }

            if !filter.shouldHide(build: build) {
                feature[groupId(for: build)] = build
            }
        }
        else {
            os_log("Builds of branches with name %{PUBLIC}@ will be ignored.", log: OSLog.builds, type: .info, build.branch)
        }
    }
}

// MARK: - Sorting
extension Builds {
    public var sortedDevelopBuilds: [BuildRepresentation] {
        return development
            .map{ $0.value }
            .sorted{ $0 < $1 }
    }

    public var sortedMasterBuilds: [BuildRepresentation] {
        return master
            .map{ $0.value }
            .sorted{ $0 < $1 }
    }

    public var sortedLatestReleaseBuilds: [BuildRepresentation] {
        return latestRelease
            .map{ $0.value }
            .sorted{ $0 < $1 }
    }

    public var sortedLatestHotfixBuilds: [BuildRepresentation] {
        return latestHotfix
            .map{ $0.value }
            .sorted{ $0 < $1 }
    }

    public var sortedFeatureBuilds: [BuildRepresentation] {
        return feature
            .map{ $0.value }
            .sorted{ $0 < $1 }
    }
}

// MARK: - Grouping
extension Builds {
    // For the build monitor we want to group everything that runs on the same branch and only show the
    // latest build (group) for that one
    func groupId(for build: BuildRepresentation) -> String {
        build.branch
    }
}
