public struct BitriseBuilds: Codable {
    public var data: [BitriseBuild]
    
    public init() {
        data = []
    }
}

// MARK: - Helpers
extension BitriseBuilds {
    func contains(branch: Branch) -> Bool {
        return data.contains(where: { $0.branch == branch })
    }

    func latestBuild(for branch: Branch) -> BitriseBuild? {
        return data
            .filter { $0.branch == branch }
            .sorted(by: { $0.triggeredAt > $1.triggeredAt })
            .first
    }
}
