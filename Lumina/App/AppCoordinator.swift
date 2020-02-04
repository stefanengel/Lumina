import AppKit
import SwiftUI

class AppCoordinator {
    private var buildMonitorWindow: NSWindow?
    private var preferencesWindow: NSWindow?

    private var buildMonitorModel: BuildMonitorModel

    init(model: BuildMonitorModel) {
        self.buildMonitorModel = model
    }
}

// MARK: - Starting the app
extension AppCoordinator {
    func start() {
        let contentView = BuildMonitorView(viewModel: BuildMonitorViewModel(model: buildMonitorModel))

        buildMonitorWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        buildMonitorWindow?.center()
        buildMonitorWindow?.setFrameAutosaveName("Main Window")
        buildMonitorWindow?.contentView = NSHostingView(rootView: contentView)
        buildMonitorWindow?.makeKeyAndOrderFront(nil)
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
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered, defer: false)
            preferencesWindow.title = "Preferences"
            preferencesWindow.center()
            preferencesWindow.isReleasedWhenClosed = true
            preferencesWindow.contentView = NSHostingView(rootView: contentView)
            preferencesWindow.isReleasedWhenClosed = false
            self.preferencesWindow = preferencesWindow
        }

        preferencesWindow?.makeKeyAndOrderFront(nil)
    }
}
