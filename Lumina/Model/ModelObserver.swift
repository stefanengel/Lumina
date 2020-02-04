import BuildStatusChecker

protocol ModelObserver: AnyObject {
    func startetLoading()
    func stoppedLoading()
    func updateFailed(error: BuildFetcherError)
    func update(builds: Builds)
}
