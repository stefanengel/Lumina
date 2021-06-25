import SwiftUI
import BuildStatusChecker

struct BuildQueueInfoView: View {
    var viewModel: BuildQueueInfoViewModel

    var body: some View {
        HStack {
            Text(viewModel.totalSlots)
            Text(viewModel.running)
            Text(viewModel.onHold)
        }
    }
}

struct BuildQueueInfoView_Previews: PreviewProvider {
    static var previews: some View {
        BuildQueueInfoView(viewModel: BuildQueueInfoViewModel(buildQueueInfo: BuildQueueInfo(totalSlots: 10, runningBuilds: 4, queuedBuilds: 0)))
    }
}
