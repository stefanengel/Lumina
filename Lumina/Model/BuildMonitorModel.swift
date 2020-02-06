import Foundation
import BuildStatusChecker

class BuildMonitorModel {
    private var buildFetcher = BuildFetcherFactory.createBuildFetcher()
    private var updateTimer: Timer?
    private var observers: [ModelObserver] = []
}

// MARK: - Start update mechanism
extension BuildMonitorModel {
    func startUpdating() {
        fetchBuilds()

        let interval = TimeInterval(SettingsStore().readUpdateInterval())
        self.updateTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(self.requestUpdate), userInfo: nil, repeats: true)
    }
}

// MARK: - Observer
extension BuildMonitorModel {
    func register(observer: ModelObserver) {
        observers.append(observer)
    }

    func unregister(observer: ModelObserver) {
        if let index = observers.firstIndex(where: { $0 === observer }) {
            observers.remove(at: index)
        }
    }

    func notifyStartedLoading() {
        for observer in observers {
            observer.startedLoading()
        }
    }

    func notifyStoppedLoading() {
        for observer in observers {
            observer.stoppedLoading()
        }
    }

    func notifyUpdateFailed(error: BuildFetcherError) {
        for observer in observers {
            observer.updateFailed(error: error)
        }
    }

    func notifyUpdateSucceeded(builds: Builds) {
        for observer in observers {
            observer.update(builds: builds)
        }
    }
}

// MARK: - Update mechanism
extension BuildMonitorModel {
    @objc func requestUpdate() {
        fetchBuilds()
    }

    private func fetchBuilds() {
        notifyStartedLoading()
        buildFetcher.getRecentBuilds() { result in
            switch result {
                case .success(let builds): self.notifyUpdateSucceeded(builds: builds)
                case .failure(let error): self.notifyUpdateFailed(error: error)
            }

            self.notifyStoppedLoading()
        }
    }
}
