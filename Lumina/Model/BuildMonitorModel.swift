import Foundation
import BuildStatusChecker
import Combine

class BuildMonitorModel {
    private var buildAPIClient: BuildAPIClient
    private var timerToken: AnyCancellable?
    private var observers: [ModelObserver] = []

    init(buildAPIClient: BuildAPIClient) {
        self.buildAPIClient = buildAPIClient
    }
}

// MARK: - Start update mechanism
extension BuildMonitorModel {
    func startUpdating() {
        fetchBuilds()

        let interval = TimeInterval(SettingsStore().settings.updateIntervalInSeconds)
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

    func notifyUpdateSucceeded(builds: Builds, buildQueueInfo: BuildQueueInfo) {
        for observer in observers {
            observer.update(builds: builds, buildQueueInfo: buildQueueInfo)
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
        buildAPIClient.getRecentBuilds() { result in
            switch result {
            case .success(let builds):
                self.buildAPIClient.getBuildQueueInfo { buildQueueInfoResult in
                    switch buildQueueInfoResult {
                        case .success(let buildQueueInfo): self.notifyUpdateSucceeded(builds: builds, buildQueueInfo: buildQueueInfo)
                        case .failure(let error): self.notifyUpdateFailed(error: error)
                    }
                }
            case .failure(let error): self.notifyUpdateFailed(error: error)
            }

            self.notifyStoppedLoading()
        }
    }
}
