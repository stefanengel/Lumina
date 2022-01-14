import SwiftUI
import BuildStatusChecker

struct BuildQueueInfoView: View {
    var viewModel: BuildQueueInfoViewModel

    var body: some View {
        VStack(alignment: .center) {
            HStack(spacing: 16) {
                Text(viewModel.runningText)
                Text(viewModel.onHoldText)
            }
            .frame(maxWidth: .infinity)
            
            if viewModel.canDisplayUsageBar {
                GeometryReader { proxy in
                    UsageBarView(
                        totalAmount: viewModel.totalAmount,
                        usedAmount: viewModel.usedAmount,
                        width: proxy.size.width
                    )
                }
                .frame(maxHeight: UsageBarView.barHeight)
            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }
}

struct BuildQueueInfoView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            BuildQueueInfoView(
                viewModel: BuildQueueInfoViewModel(
                    buildQueueInfo: BuildQueueInfo(totalSlots: 10, runningBuilds: 4, queuedBuilds: 0)
                )
            )
            BuildQueueInfoView(
                viewModel: BuildQueueInfoViewModel(
                    buildQueueInfo: BuildQueueInfo(totalSlots: nil, runningBuilds: 4, queuedBuilds: 0)
                )
            )
        }
    }
}
