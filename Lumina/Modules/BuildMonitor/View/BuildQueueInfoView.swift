import SwiftUI
import BuildStatusChecker

struct BuildQueueInfoView: View {
    var viewModel: BuildQueueInfoViewModel

    var body: some View {
        HStack {
            HStack(spacing: 8) {
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
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
s        .padding(.top, 8)
    }
}

struct BuildQueueInfoView_Previews: PreviewProvider {
    static var previews: some View {
        BuildQueueInfoView(viewModel: BuildQueueInfoViewModel(buildQueueInfo: BuildQueueInfo(totalSlots: 10, runningBuilds: 4, queuedBuilds: 0)))
    }
}
