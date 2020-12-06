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
        statusItem.button?.image =  NSImage(imageLiteralResourceName: "StatusBarButtonImage")
        statusItem.menu = NSMenu()
        addDefaultMenuItems()
    }

    func update() {
        statusItem.menu = NSMenu()

        let branches = [viewModel.master, viewModel.development, viewModel.release, viewModel.hotfix]
        for branchBuilds in branches {
            for build in branchBuilds {
                statusItem.menu?.addItem(statusItem(for: build))
            }
        }

        statusItem.menu?.addItem(NSMenuItem.separator())

        for featureBuild in viewModel.feature {
            statusItem.menu?.addItem(statusItem(for: featureBuild))
        }

        addDefaultMenuItems()
    }
    
    private func addDefaultMenuItems() {
        statusItem.menu?.addItem(NSMenuItem.separator())
        statusItem.menu?.addItem(withTitle: "Open Main Window...", action: #selector(AppDelegate.openMainWindow(_:)), keyEquivalent: "")
        statusItem.menu?.addItem(withTitle: "Preferences...", action: #selector(AppDelegate.openPreferences(_:)), keyEquivalent: ",")
        statusItem.menu?.addItem(NSMenuItem.separator())
        statusItem.menu?.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    }

    @objc func openInBrowser(sender: Any) {
        if let item = sender as? NSMenuItem, let build = item.representedObject as? Build {
            viewModel.openInBrowser(build: build)
        }
    }
}

// MARK: - Mapping builds to status items
extension StatusItemView {
    func statusItem(for build: BuildRepresentation) -> NSMenuItem {
        let statusAttributedString = NSMutableAttributedString()
        statusAttributedString.append(NSAttributedString(string: "●", attributes: viewModel.attributes(for: build.wrapped.status)))
        statusAttributedString.append(NSAttributedString(string: " \(build.wrapped.branch)"))

        if build.subBuilds.isEmpty {
            if let info = build.wrapped.info {
                statusAttributedString.append(NSMutableAttributedString(string: " - \(info)"))
            }
        }
        else {
            for build in build.subBuilds {
                if let workflow = build.groupItemDescription {
                    let workflowAttributedString = NSMutableAttributedString()
                    workflowAttributedString.append(NSAttributedString(string: " ["))
                    workflowAttributedString.append(NSAttributedString(string: "●", attributes: viewModel.attributes(for: build.wrapped.status)))
                    workflowAttributedString.append(NSAttributedString(string: " \(workflow)]"))
                    statusAttributedString.append(workflowAttributedString)
                }
            }
        }

        let menuItem = NSMenuItem(title: build.wrapped.branch, action: #selector(openInBrowser(sender:)), keyEquivalent: "")
        menuItem.attributedTitle = statusAttributedString
        menuItem.target = self
        menuItem.representedObject = build.wrapped

        return menuItem
    }
}

// MARK: StatusItemViewDelegate
extension StatusItemView: StatusItemViewDelegate {
    func updateMenu() {
        update()
    }
}
