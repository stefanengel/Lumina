import SwiftUI
import BuildStatusChecker

struct BuildQueueInfoView: View {
    var viewModel: BuildQueueInfoViewModel

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                if viewModel.numberOfTotalSlotsKnown {
                    ForEach(0...viewModel.totalSlots - 1, id: \.self) { index in
                        if viewModel.slotIsFree(slotIndex: index) {
                            Circle()
                                .fill(Colors.emerald)
                                .frame(width: 20, height: 20)
                        }
                        else {
                            Circle()
                                .fill(Colors.alizarin)
                                .frame(width: 20, height: 20)
                        }
                    }
                    Text(viewModel.onHoldText)
                }
                else {
                    Text(viewModel.numberOfTotalSlotsUnknownText)
                }
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
