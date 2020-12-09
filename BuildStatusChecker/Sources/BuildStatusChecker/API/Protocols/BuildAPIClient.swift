public protocol BuildAPIClient {
    func getRecentBuilds(completion: @escaping (Result<Builds, BuildAPIClientError>) -> Void)
}

