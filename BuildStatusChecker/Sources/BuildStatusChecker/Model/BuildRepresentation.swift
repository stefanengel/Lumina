import Foundation

public struct BuildRepresentation {
    public let wrapped: BuildProtocol
    private let settings: Settings

    public init(wrapped: BuildProtocol, settings: Settings) {
        self.wrapped = wrapped
        self.settings = settings
    }
}

extension BuildRepresentation: BuildProtocol {
    public var id: String {
        wrapped.id
    }

    public var buildNumber: Int {
        wrapped.buildNumber
    }

    public var parentBuildNumber: Int? {
        wrapped.parentBuildNumber
    }

    public var status: BuildStatus {
        wrapped.status
    }

    public var branch: Branch {
        wrapped.branch
    }

    public var triggeredAt: Date {
        wrapped.triggeredAt
    }

    public var startedAt: Date? {
        wrapped.startedAt
    }

    public var url: String {
        wrapped.url
    }

    public var info: String? {
        wrapped.info
    }

    public var commitHash: String {
        wrapped.commitHash
    }

    public var groupId: String? {
        wrapped.groupId
    }

    public var groupItemDescription: String? {
        wrapped.groupItemDescription
    }

    public var originalBuildParameters: OriginalBuildParams? {
        wrapped.originalBuildParameters
    }

    public var isGroupedBuild: Bool {
        wrapped is GroupedBuild
    }

    public var subBuilds: [BuildRepresentation] {
        (wrapped as? GroupedBuild)?.builds ?? []
    }
}

extension BuildRepresentation: Hashable {
    public static func == (lhs: BuildRepresentation, rhs: BuildRepresentation) -> Bool {
        lhs.branch == rhs.branch
            && lhs.groupId == rhs.groupId
            && lhs.groupItemDescription == rhs.groupItemDescription
            && lhs.info == rhs.info
            && lhs.url == rhs.url
            && lhs.startedAt == rhs.startedAt
            && lhs.triggeredAt == rhs.triggeredAt
            && lhs.status == rhs.status
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(branch)
        hasher.combine(groupId)
        hasher.combine(groupItemDescription)
        hasher.combine(info)
        hasher.combine(url)
        hasher.combine(startedAt)
        hasher.combine(triggeredAt)
        hasher.combine(status)
    }
}

extension BuildRepresentation: Comparable {
    public static func < (lhs: BuildRepresentation, rhs: BuildRepresentation) -> Bool {
        if lhs.wrapped.branch != rhs.wrapped.branch {
            return lhs.wrapped.branch < rhs.wrapped.branch
        }

        return lhs.wrapped.triggeredAt < rhs.wrapped.triggeredAt
    }
}

// MARK: - GitFlow specifics
extension BuildRepresentation {
    public var isDevelopBranch: Bool {
        return wrapped.branch == settings.developBranchName
    }

    public var isMasterBranch: Bool {
        return wrapped.branch == settings.masterBranchName
    }

    public var isReleaseBranch: Bool {
        return wrapped.branch.starts(with: settings.releaseBranchPrefix)
    }

    public var isHotfixBranch: Bool {
        return wrapped.branch.starts(with: settings.hotfixBranchPrefix)
    }

    public var isFeatureBranch: Bool {
        return wrapped.branch.starts(with: settings.featureBranchPrefix)
    }
}
