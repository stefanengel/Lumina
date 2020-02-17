import BuildStatusChecker

protocol ModelObserver: AnyObject {
    func startedLoading()
    func stoppedLoading()
    func updateFailed(error: BuildFetcherError)
    func update(builds: Builds)
}
