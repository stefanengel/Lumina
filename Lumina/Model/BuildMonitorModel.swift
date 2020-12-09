import Foundation
import BuildStatusChecker
import Combine

class BuildMonitorModel {
    private var buildFetcher = BuildAPIClientFactory.createBuildAPI()
    private var timerToken: AnyCancellable?
    private var observers: [ModelObserver] = []
}

// MARK: - Start update mechanism
extension BuildMonitorModel {
    func startUpdating() {
        fetchBuilds()

        let interval = TimeInterval(SettingsStore().readUpdateInterval())
        let timer = Timer.publish(every: interval, on: .main, in: .common).autoconnect()
        self.timerToken = timer.sink(receiveValue: {[weak self] _ in
            self?.fetchBuilds()
        })
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

    func notifyUpdateFailed(error: BuildAPIClientError) {
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
        timerToken?.cancel()
        startUpdating()
    }

    @objc private func fetchBuilds() {
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
