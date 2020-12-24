import Foundation

public class GroupedBuild: BuildProtocol {
    public var buildNumber: Int {
        builds.first?.buildNumber ?? 0
    }

    public var parentBuildNumber: Int? {
        builds.first?.parentBuildNumber
    }

    public var id: String {
        builds.first!.id // This should crash if there is no build in a group!
    }

    public var status: BuildStatus {
        builds.first?.status ?? .unknown
    }

    public var branch: Branch {
        builds.first?.branch ?? "Unknown branch"
    }

    public var triggeredAt: Date {
        builds.first?.triggeredAt ?? Date()
    }

    public var startedAt: Date? {
        builds.first?.startedAt
    }

    public var url: String {
        builds.first!.url
    }

    public var info: String? {
        builds.first?.info
    }

    public var commitHash: String {
        builds.first?.commitHash ?? "Unknown commit hash"
    }

    public var groupId: String? {
        builds.first?.groupId
    }

    public var groupItemDescription: String? {
        builds.first?.groupItemDescription
    }

    public var originalBuildParameters: Codable? {
        builds.first?.originalBuildParameters
    }

    public var builds: [BuildRepresentation]

    public init(builds: [BuildRepresentation]) {
        if builds.isEmpty {
            assertionFailure("Cannot initialize a GroupedBuild with 0 builds!")
        }
        self.builds = builds.sorted{ $0 < $1 }
    }

    public func append(build: BuildRepresentation) {
        builds.append(build)
        self.builds = builds.sorted{ $0 < $1 }
    }
}
