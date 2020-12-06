import Foundation

public typealias Branch = String

public struct Build: BuildProtocol {
    public var buildNumber: Int
    public var parentBuildNumber: Int?
    public let status: BuildStatus
    public let branch: Branch
    public let triggeredAt: Date
    public let startedAt: Date?
    public let url: String
    // General info where special properties can be stored that are not easy to generalize for all providers
    // For example, bitrise builds will store the triggered_workflow here
    public let info: String?
    public let commitHash: String

    public let groupId: String?
    public let groupItemDescription: String?

    private let settings: SettingsStoreProtocol = SettingsStore()

    public var id: String {
        "\(branch)_\(info ?? "")"
    }

    public init(buildNumber: Int, parentBuildNumber: Int? = nil, status: BuildStatus, branch: Branch, triggeredAt: Date, startedAt: Date? = nil, url: String, info: String? = nil, commitHash: String, groupId: String? = nil, groupItemDescription: String? = nil) {
        self.buildNumber = buildNumber
        self.parentBuildNumber = parentBuildNumber
        self.status = status
        self.branch = branch
        self.triggeredAt = triggeredAt
        self.startedAt = startedAt
        self.url = url
        self.info = info
        self.commitHash = commitHash
        self.groupId = groupId
        self.groupItemDescription = groupItemDescription
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

// MARK: Comparable
extension Build: Comparable {
    public static func <(lhs: Build, rhs: Build) -> Bool {
        if lhs.branch != rhs.branch {
            return lhs.branch < rhs.branch
        }

        return lhs.triggeredAt < rhs.triggeredAt
    }
}
