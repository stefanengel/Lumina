import Foundation

public protocol BuildProtocol {
    var id: String { get }
    var buildNumber: Int { get }
    var parentBuildNumber: Int? { get }
    var status: BuildStatus { get }
    var branch: Branch { get }
    var triggeredAt: Date { get }
    var startedAt: Date? { get }
    var url: String { get }
    // General info where special properties can be stored that are not easy to generalize for all providers
    // For example, bitrise builds will store the triggered_workflow here
    var info: String? { get }
    var commitHash: String { get }

    var groupId: String? { get }
    var groupItemDescription: String? { get }
    // The original build parameters can be used to retrigger a build
    var originalBuildParameters: Codable? { get }
}
