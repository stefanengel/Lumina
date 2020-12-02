import AppKit
import SwiftUI
import CoreGraphics
import BuildStatusChecker

class AppCoordinator: NSObject {
    private var buildMonitorWindow: NSWindow?
    private var preferencesWindow: NSWindow?

    private var buildMonitorModel: BuildMonitorModel

    private var rootLayer: CALayer = CALayer()
    private var emitterLayer: CAEmitterLayer = CAEmitterLayer()

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

            createFireWorks()

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

// MARK: - Fancy snow effect
extension AppCoordinator {
    func createFireWorks() {
        guard let mainView = buildMonitorWindow?.contentView else { return }

        let image = NSImage(named: "snow")
        let img:CGImage = (image?.cgImage(forProposedRect: nil, context: nil, hints: nil))!

        let flakeEmitterCell = CAEmitterCell()
        flakeEmitterCell.contents = img
        flakeEmitterCell.scale = 0.06
        flakeEmitterCell.scaleRange = 0.3
        flakeEmitterCell.emissionRange = .pi
        flakeEmitterCell.lifetime = 20.0
        flakeEmitterCell.birthRate = 20
        flakeEmitterCell.velocity = -30
        flakeEmitterCell.velocityRange = -20
        flakeEmitterCell.yAcceleration = 30
        flakeEmitterCell.xAcceleration = 5
        flakeEmitterCell.spin = -0.5
        flakeEmitterCell.spinRange = 1.0

        let snowEmitterLayer = CAEmitterLayer()
        snowEmitterLayer.emitterPosition = CGPoint(x: mainView.bounds.width / 2.0, y: -50)
        snowEmitterLayer.emitterSize = CGSize(width: mainView.bounds.width, height: 0)
        snowEmitterLayer.emitterShape = CAEmitterLayerEmitterShape.line
        snowEmitterLayer.beginTime = CACurrentMediaTime()
        snowEmitterLayer.timeOffset = 10
        snowEmitterLayer.emitterCells = [flakeEmitterCell]
        snowEmitterLayer.backgroundColor = CGColor.clear

        let snowView = SnowView(frame: mainView.frame)
        snowView.frame = mainView.bounds
        self.rootLayer.addSublayer(snowEmitterLayer)
        snowView.layer = rootLayer
        snowView.wantsLayer = true
        snowView.needsDisplay = true
        snowView.autoresizingMask = [.width, .height]

        mainView.addSubview(snowView)
        mainView.autoresizesSubviews = true
    }
}

class SnowView: NSView {
    override var isFlipped: Bool { true }
}
