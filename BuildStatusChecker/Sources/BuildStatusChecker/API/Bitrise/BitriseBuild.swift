import Foundation

public enum BitriseBuildStatus: Int {
    case running = 0
    case successful = 1
    case failed = 2
    case abortedWithFailure = 3
    case abortedWithSuccess = 4
}

extension BitriseBuildStatus: Codable {}

public struct BitriseBuild: Codable {
    let buildNumber: Int
    let triggeredAt: Date
    let startedOnWorkerAt: Date?
    let finishedAt: Date?
    let status: BitriseBuildStatus
    let branch: String
    let abortReason: String?
    let slug: String
    let triggeredWorkflow: String
    let triggeredBy: String?
    let commitHash: String?
    let commitMessage: String?
    let isOnHold: Bool
    let originalBuildParams: OriginalBuildParams?

    var parentBuildNumber: Int? {
        originalBuildParams?.sourceBitriseBuildNumber
    }

    var groupId: String {
        if let commitHash = commitHash {
            return "\(commitHash)_\(parentBuildNumber ?? buildNumber)"
        } else {
            return "\(parentBuildNumber ?? buildNumber)"
        }
    }

    var info: String {
        let settings = BitriseStore()

        if settings.groupByBuildNumber {
            if let commitMessage = commitMessage?.split(separator: "\n").first {
                return "\(commitMessage)"
            }
        }

        return "\(triggeredWorkflow)"
    }
}

// MARK: - Conversion
extension BitriseBuild {
    public var asBuildRepresentation: BuildRepresentation {
        let bitriseStore = BitriseStore()

        var groupId: String?
        var groupItemDescription: String?

        if bitriseStore.groupByBuildNumber {
            groupId = self.groupId
            groupItemDescription = triggeredWorkflow
        }

        var buildStatus: BuildStatus = .unknown
        switch status {
            case .running: buildStatus = BuildStatus.running
            case .successful: buildStatus = BuildStatus.success
            case .failed: buildStatus = BuildStatus.failed(error: nil)
            case .abortedWithFailure, .abortedWithSuccess: buildStatus = BuildStatus.aborted(reason: abortReason)
        }

        let url = "https://app.bitrise.io/build/\(slug)#?tab=log"

        return BuildRepresentation(wrapped: Build(id: slug, buildNumber: buildNumber, parentBuildNumber: originalBuildParams?.sourceBitriseBuildNumber, status: buildStatus, branch: branch, triggeredAt: triggeredAt, startedAt: startedOnWorkerAt, url: url, info: info, commitHash: commitHash ?? "Unknown commit hash", groupId: groupId, groupItemDescription: groupItemDescription, originalBuildParameters: originalBuildParams))
    }
}
