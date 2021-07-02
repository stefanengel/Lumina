import SwiftUI
import BuildStatusChecker

struct BuildQueueInfoView: View {
    var viewModel: BuildQueueInfoViewModel

    var body: some View {
        HStack {
            Text(viewModel.totalSlots)
                .foregroundColor(Color.white)
            Text(viewModel.running)
                .foregroundColor(Color.white)
            Text(viewModel.onHold)
                .foregroundColor(Color.white)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(viewModel.backgroundColor)
    }
}

struct BuildQueueInfoView_Previews: PreviewProvider {
    static var previews: some View {
        BuildQueueInfoView(viewModel: BuildQueueInfoViewModel(buildQueueInfo: BuildQueueInfo(totalSlots: 10, runningBuilds: 4, queuedBuilds: 0)))
    }
}
