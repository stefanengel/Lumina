import AppKit
import SwiftUI
import BuildStatusChecker

class AppCoordinator: NSObject {
    private var buildMonitorWindow: NSWindow?
    private var preferencesWindow: NSWindow?

    private var buildMonitorModel: BuildMonitorModel

    init(model: BuildMonitorModel) {
        self.buildMonitorModel = model
        super.init()

        model.register(observer: self)
    }

    deinit {
        buildMonitorModel.unregister(observer: self)
    }
}

// MARK: - Starting the app
extension AppCoordinator {
    func start() {
        if buildMonitorWindow == nil {
            let contentView = BuildMonitorView(viewModel: BuildMonitorViewModel(model: buildMonitorModel))

            buildMonitorWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 480, height: 600),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered, defer: false)
            buildMonitorWindow?.center()
            buildMonitorWindow?.title = "Lumina"
            buildMonitorWindow?.setFrameAutosaveName("Main Window")
            buildMonitorWindow?.contentView = NSHostingView(rootView: contentView)
            buildMonitorWindow?.isReleasedWhenClosed = false
            buildMonitorWindow?.makeKeyAndOrderFront(nil)

            buildMonitorModel.startUpdating()
        } else {
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}


// MARK: - Updating
extension AppCoordinator {
    func updateBuildMonitor() {
        buildMonitorModel.requestUpdate()
    }
}

// MARK: - Preferences
extension AppCoordinator {
    func openPreferences() {
        if preferencesWindow == nil {
            let contentView = PreferencesView(viewModel: PreferencesViewModel())

            let preferencesWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 300),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered, defer: false)
            preferencesWindow.title = "Preferences"
            buildMonitorWindow?.setFrameAutosaveName("Preferences Window")
            preferencesWindow.center()
            preferencesWindow.contentView = NSHostingView(rootView: contentView)
            preferencesWindow.isReleasedWhenClosed = false
            preferencesWindow.delegate = self
            self.preferencesWindow = preferencesWindow

            preferencesWindow.makeKeyAndOrderFront(nil)
        }
    }
}

// MARK: - Checking if settings are incomplete
extension AppCoordinator: ModelObserver {
    func startedLoading() {
    }

    func stoppedLoading() {
    }

    func updateFailed(error: BuildFetcherError) {
        switch error {
            case .incompleteProviderConfiguration: openPreferences()
            default: break
        }
    }

    func update(builds: Builds) {
    }
}

// MARK: - NSWindowDelegate (used for preferencesWindow)
extension AppCoordinator: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        preferencesWindow = nil
    }
}
