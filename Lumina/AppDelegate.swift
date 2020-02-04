import Cocoa
import SwiftUI
import BuildStatusChecker

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var appCoordinator: AppCoordinator?
    var statusItemCoordinator: StatusItemCoordinator?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let model = BuildMonitorModel()

        statusItemCoordinator = StatusItemCoordinator()
        statusItemCoordinator?.start(model: model)

        appCoordinator = AppCoordinator(model: model)
        appCoordinator?.start()
    }

    @IBAction func refreshView(_ sender: Any) {
        appCoordinator?.updateBuildMonitor()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    @IBAction func openPreferences(_ sender: Any) {
        appCoordinator?.openPreferences()
    }
}
