public protocol BuildAPIClient {
    func getRecentBuilds(completion: @escaping (Result<Builds, BuildAPIClientError>) -> Void)
    func triggerBuild(buildParams: GenericBuildParams)
    func cancelBuild(buildId: String)
    func getBuildQueueInfo(completion: @escaping (Result<BuildQueueInfo, BuildAPIClientError>) -> Void)
}

