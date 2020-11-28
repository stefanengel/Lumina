import Foundation

public protocol BuildProtocol {
    var id: String { get }
    var status: BuildStatus { get }
    var branch: Branch { get }
    var triggeredAt: Date { get }
    var startedAt: Date? { get }
    var url: String { get }
    // General info where special properties can be stored that are not easy to generalize for all providers
    // For example, bitrise builds will store the triggered_workflow here
    var info: String? { get }

    var groupId: String? { get }
    var groupItemDescription: String? { get }
}
