public struct BuildAbortParams: Codable {
    let abortReason: String
    let abortWithSuccess, skipNotifications: Bool

    enum CodingKeys: String, CodingKey {
        case abortReason = "abort_reason"
        case abortWithSuccess = "abort_with_success"
        case skipNotifications = "skip_notifications"
    }
}
