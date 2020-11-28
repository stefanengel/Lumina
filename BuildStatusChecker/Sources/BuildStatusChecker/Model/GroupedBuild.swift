import Foundation

class GroupedBuild: BuildProtocol {
    public var id: String {
        if let info = info {
            return "\(branch)_\(info)"
        }
        else {
            return branch
        }
    }

    var status: BuildStatus {
        builds.first?.status ?? .unknown
    }

    var branch: Branch {
        builds.first?.branch ?? "Unknown branch"
    }

    var triggeredAt: Date {
        builds.first?.triggeredAt ?? Date()
    }

    var startedAt: Date? {
        builds.first?.startedAt
    }

    var url: String {
        builds.first!.url
    }

    var info: String? {
        builds.first?.info
    }

    var groupId: String? {
        builds.first?.groupId
    }

    var groupItemDescription: String? {
        builds.first?.groupItemDescription
    }

    var builds: [BuildRepresentation]

    init(builds: [BuildRepresentation]) {
        if builds.isEmpty {
            assertionFailure("Cannot initialize a GroupedBuild with 0 builds!")
        }
        self.builds = builds.sorted{ $0 < $1 }
    }

    func append(build: BuildRepresentation) {
        builds.append(build)
    }
}
