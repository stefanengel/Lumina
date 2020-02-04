public struct BitriseBuilds: Codable {
    public var data: [BitriseBuild]
    
    public init() {
        data = []
    }
}

// MARK: - Helpers
extension BitriseBuilds {
    func contains(branch: Branch) -> Bool {
        for build in data {
            if build.branch == branch { return true }
        }

        return false
    }

    func latestBuild(for branch: Branch) -> BitriseBuild? {
        var result: BitriseBuild?

        for build in data where build.branch == branch {
            if let newestBuild = result, build.startedOnWorkerAt > newestBuild.startedOnWorkerAt {
                result = build
            }
            else if result == nil {
                result = build
            }
        }

        return result
    }
}
