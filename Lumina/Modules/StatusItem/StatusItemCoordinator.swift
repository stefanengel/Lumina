import AppKit
import BuildStatusChecker

class StatusItemCoordinator {
    private var view: StatusItemView?
    private var viewModel: StatusItemViewModel?

    func start(model: BuildMonitorModel) {
        let vm = StatusItemViewModel(model: model)
        view = StatusItemView(viewModel: vm)
        viewModel = vm
    }
}
