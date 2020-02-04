public protocol BuildFetcher {
    func getRecentBuilds(completion: @escaping (Result<Builds, BuildFetcherError>) -> Void)
}

