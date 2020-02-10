import os.log

public class Builds {
    public var development: Build?
    public var master: Build?
    public var latestRelease: Build?
    public var latestHotfix: Build?
    public var feature: [String: Build] = [:]
    public var filter: BuildFilter = BuildFilter()

    public func add(build: Build) {
        if build.isDevelopBranch {
            if let currentDevelopBuild = development, currentDevelopBuild.triggeredAt > build.triggeredAt {
                return
            }

            development = build
        }
        else if build.isMasterBranch {
            if let currentMasterBuild = master, currentMasterBuild.triggeredAt > build.triggeredAt {
                return
            }

            master = build
        }
        else if build.isReleaseBranch {
            if let existingReleaseBuild = latestRelease, existingReleaseBuild.triggeredAt > build.triggeredAt {
                return
            }

            latestRelease = build
        }
        else if build.isHotfixBranch {
            if let existingHotfixBuild = latestHotfix, existingHotfixBuild.triggeredAt > build.triggeredAt {
                return
            }

            latestHotfix = build
        }
        else if build.isFeatureBranch {
            if let existingFeatureBuild = feature[build.branch], existingFeatureBuild.triggeredAt > build.triggeredAt {
                return
            }

            if !filter.shouldHide(build: build) {
                feature[build.branch] = build
            }
        }
        else {
            os_log("Builds of branches with name %{PUBLIC}@ will be ignored.", log: OSLog.builds, type: .info, build.branch)
        }
    }
}

// MARK: - Sorting
extension Builds {
    public var sortedFeatureBuilds: [Build] {
        return feature
            .map{ $0.value }
            .sorted{ $0.branch < $1.branch }
    }
}
