import BuildStatusChecker

class BuildAPIClientMock: BuildAPIClient {
    func getRecentBuilds(completion: @escaping (Result<Builds, BuildAPIClientError>) -> Void) {
    }

    func triggerBuild(buildParams: GenericBuildParams) {
    }

    func cancelBuild(buildId: String) {
    }

    func getBuildQueueInfo(completion: @escaping (Result<BuildQueueInfo, BuildAPIClientError>) -> Void) {
    }

    static func create() -> BuildAPIClient {
        BuildAPIClientMock()
    }
}
