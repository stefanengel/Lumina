import Foundation

public typealias Branch = String

public struct Build {
    public let status: BuildStatus
    public let branch: Branch
    public let triggeredAt: Date
    public let startedAt: Date?
    public let url: String

    private let settings: SettingsStoreProtocol = SettingsStore()

    public init(status: BuildStatus, branch: Branch, triggeredAt: Date, startedAt: Date? = nil, url: String) {
        self.status = status
        self.branch = branch
        self.triggeredAt = triggeredAt
        self.startedAt = startedAt
        self.url = url
    }
}

// MARK: - Hashable
extension Build: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(status)
        hasher.combine(branch)
        hasher.combine(triggeredAt)
    }
}

// MARK: - Equatable
extension Build: Equatable {
    public static func == (lhs: Build, rhs: Build) -> Bool {
        return lhs.status == rhs.status
            && lhs.branch == rhs.branch
            && lhs.triggeredAt == rhs.triggeredAt
            && lhs.startedAt == rhs.startedAt
            && lhs.url == rhs.url
    }
}

// MARK: - GitFlow specifics
extension Build {
    public var isDevelopBranch: Bool {
        return branch == settings.read(setting: .developBranchName)
    }

    public var isMasterBranch: Bool {
        return branch == settings.read(setting: .masterBranchName)
    }

    public var isReleaseBranch: Bool {
        return branch.starts(with: settings.read(setting: .releaseBranchPrefix))
    }

    public var isHotfixBranch: Bool {
        return branch.starts(with: settings.read(setting: .hotfixBranchPrefix))
    }

    public var isFeatureBranch: Bool {
        return branch.starts(with: settings.read(setting: .featureBranchPrefix))
    }
}
