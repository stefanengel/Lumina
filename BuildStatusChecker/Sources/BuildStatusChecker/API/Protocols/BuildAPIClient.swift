public protocol BuildAPIClient {
    func getRecentBuilds(completion: @escaping (Result<Builds, BuildAPIClientError>) -> Void)
    func triggerBuild(buildId: String)
    func cancelBuild(buildId: String)
}

