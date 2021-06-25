import BuildStatusChecker

protocol ModelObserver: AnyObject {
    func startedLoading()
    func stoppedLoading()
    func updateFailed(error: BuildAPIClientError)
    func update(builds: Builds, buildQueueInfo: BuildQueueInfo)
}
