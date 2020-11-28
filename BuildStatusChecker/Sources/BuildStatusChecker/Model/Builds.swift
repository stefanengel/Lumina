import os.log

public class Builds {
    public var development: [String: BuildRepresentation] = [:]
    public var master: [String: BuildRepresentation] = [:]
    public var latestRelease: [String: BuildRepresentation] = [:]
    public var latestHotfix: [String: BuildRepresentation] = [:]
    public var feature: [String: BuildRepresentation] = [:]
    public var filter: BuildFilter = BuildFilter()

    public func add(build: BuildRepresentation) {
        if build.isDevelopBranch {
            if let existingDevelopBuild = development[build.id], existingDevelopBuild.wrapped.triggeredAt > build.wrapped.triggeredAt {
                return
            }

            if !filter.shouldHide(build: build) {
                development[build.id] = build
            }
        }
        else if build.isMasterBranch {
            if let existingMasterBuild = master[build.id], existingMasterBuild.triggeredAt > build.triggeredAt {
                return
            }

            if !filter.shouldHide(build: build) {
                master[build.id] = build
            }
        }
        else if build.isReleaseBranch {
            if let existingReleaseBuild = latestRelease[build.id], existingReleaseBuild.triggeredAt > build.triggeredAt {
                return
            }

            if !filter.shouldHide(build: build) {
                latestRelease[build.id] = build
            }
        }
        else if build.isHotfixBranch {
            if let existingHotfixBuild = latestHotfix[build.id], existingHotfixBuild.triggeredAt > build.triggeredAt {
                return
            }

            if !filter.shouldHide(build: build) {
                latestHotfix[build.id] = build
            }
        }
        else if build.isFeatureBranch {
            if let existingFeatureBuild = feature[build.id], existingFeatureBuild.triggeredAt > build.triggeredAt {
                return
            }

            if !filter.shouldHide(build: build) {
                feature[build.id] = build
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
