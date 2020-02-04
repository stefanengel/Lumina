public enum BuildStatus: Equatable, Hashable {
    case success
    case running
    case aborted(reason: String?)
    case failed(error: String?)
    case unknown
}
