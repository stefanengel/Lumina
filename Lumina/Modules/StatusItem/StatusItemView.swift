import AppKit
import BuildStatusChecker

protocol StatusItemViewDelegate {
    func updateMenu()
}

class StatusItemView: NSObject {
    private let viewModel: StatusItemViewModel
    private let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)


    init(viewModel: StatusItemViewModel) {
        self.viewModel = viewModel
        super.init()
        viewModel.viewDelegate = self

        statusItem.button?.title = viewModel.title
        statusItem.button?.image =  NSImage(named:NSImage.Name("StatusBarButtonImage"))
        statusItem.menu = NSMenu()
        statusItem.menu?.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    }

    func update() {
        statusItem.menu = NSMenu()

        let branches = [viewModel.master, viewModel.development, viewModel.release, viewModel.hotfix]
        for case let branch? in branches {
             statusItem.menu?.addItem(statusItem(for: branch))
        }

        statusItem.menu?.addItem(NSMenuItem.separator())

        for featureBuild in viewModel.feature {
            statusItem.menu?.addItem(statusItem(for: featureBuild))
        }

        statusItem.menu?.addItem(NSMenuItem.separator())
        statusItem.menu?.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    }

    @objc func printTest(sender: Any) {
        if let item = sender as? NSMenuItem, let build = viewModel.build(for: item.title) {
            viewModel.openInBrowser(build: build)
        }
    }
}

// MARK: - Mapping builds to status items
extension StatusItemView {
    func statusItem(for build: Build) -> NSMenuItem {
        let attributedTitle = NSAttributedString(string: build.branch, attributes: viewModel.attributes(for: build.status))
        let menuItem = NSMenuItem(title: build.branch, action: #selector(printTest(sender:)), keyEquivalent: "")
        menuItem.attributedTitle = attributedTitle
        menuItem.target = self

        return menuItem
    }
}

// MARK: StatusItemViewDelegate
extension StatusItemView: StatusItemViewDelegate {
    func updateMenu() {
        update()
    }
}
