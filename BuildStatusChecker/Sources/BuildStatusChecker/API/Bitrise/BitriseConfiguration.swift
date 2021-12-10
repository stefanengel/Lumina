public struct BitriseConfiguration {
    public let authToken: String
    public var baseUrl: String
    public var appSlug: String
    public var orgSlug: String

    public init(authToken: String, baseUrl: String, appSlug: String, orgSlug: String) {
        self.authToken = authToken
        self.baseUrl = baseUrl
        self.appSlug = appSlug
        self.orgSlug = orgSlug
    }

    public var isComplete: Bool {
        return ![authToken, baseUrl, appSlug]
            .map { $0.isEmpty }
            .contains(true)
    }
}
