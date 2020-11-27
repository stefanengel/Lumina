import os.log

public class Builds {
    public var development: [String: Build] = [:]
    public var master: [String: Build] = [:]
    public var latestRelease: [String: Build] = [:]
    public var latestHotfix: [String: Build] = [:]
    public var feature: [String: Build] = [:]
    public var filter: BuildFilter = BuildFilter()

    public func add(build: Build) {
        if build.isDevelopBranch {
            if let existingDevelopBuild = development[build.id], existingDevelopBuild.triggeredAt > build.triggeredAt {
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
    public var sortedDevelopBuilds: [Build] {
        return development
            .map{ $0.value }
            .sorted{ $0.branch < $1.branch }
    }

    public var sortedMasterBuilds: [Build] {
        return master
            .map{ $0.value }
            .sorted{ $0.branch < $1.branch }
    }

    public var sortedLatestReleaseBuilds: [Build] {
        return latestRelease
            .map{ $0.value }
            .sorted{ $0.branch < $1.branch }
    }

    public var sortedLatestHotfixBuilds: [Build] {
        return latestHotfix
            .map{ $0.value }
            .sorted{ $0.branch < $1.branch }
    }
    public var sortedFeatureBuilds: [Build] {
        return feature
            .map{ $0.value }
            .sorted{ $0.branch < $1.branch }
    }
}
