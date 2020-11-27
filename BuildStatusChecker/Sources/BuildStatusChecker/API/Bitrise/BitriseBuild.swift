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
    let triggeredAt: Date
    let startedOnWorkerAt: Date?
    let finishedAt: Date?
    let status: BitriseBuildStatus
    let branch: String
    let abortReason: String?
    let slug: String
    let triggeredWorkflow: String
}

// MARK: - Conversion
extension BitriseBuild {
    public var asBuild: Build {
        var buildStatus: BuildStatus = .unknown
        switch status {
            case .running: buildStatus = BuildStatus.running
            case .successful: buildStatus = BuildStatus.success
            case .failed: buildStatus = BuildStatus.failed(error: nil)
            case .abortedWithFailure, .abortedWithSuccess: buildStatus = BuildStatus.aborted(reason: abortReason)
        }

        let url = "https://app.bitrise.io/build/\(slug)#?tab=log"
        return Build(status: buildStatus, branch: branch, triggeredAt: triggeredAt, startedAt: startedOnWorkerAt, url: url, info: triggeredWorkflow)
    }
}
