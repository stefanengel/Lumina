import Foundation

public typealias Branch = String

public struct Build {
    public let status: BuildStatus
    public let branch: Branch
    public let triggeredAt: Date
    public let startedAt: Date?
    public let url: String
    // General info where special properties can be stored that are not easy to generalize for all providers
    // For example, bitrise builds will store the triggered_workflow here
    public let info: String?

    private let settings: SettingsStoreProtocol = SettingsStore()

    var id: String {
        if let info = info {
            return "\(branch)_\(info)"
        }
        else {
            return branch
        }
    }

    public init(status: BuildStatus, branch: Branch, triggeredAt: Date, startedAt: Date? = nil, url: String, info: String? = nil) {
        self.status = status
        self.branch = branch
        self.triggeredAt = triggeredAt
        self.startedAt = startedAt
        self.url = url
        self.info = info
    }
}

// MARK: - Hashable
extension Build: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(status)
        hasher.combine(branch)
        hasher.combine(triggeredAt)
        hasher.combine(startedAt)
        hasher.combine(url)
        hasher.combine(info)
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
            && lhs.info == rhs.info
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
