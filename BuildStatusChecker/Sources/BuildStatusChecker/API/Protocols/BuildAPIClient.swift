public protocol BuildAPIClient {
    func getRecentBuilds(completion: @escaping (Result<Builds, BuildAPIClientError>) -> Void)
    func triggerBuild(buildParams: GenericBuildParams)
    func cancelBuild(buildId: String)
}

