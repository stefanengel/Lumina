import SwiftUI
import BuildStatusChecker

class BuildQueueInfoViewModel: ObservableObject {
    let buildQueueInfo: BuildQueueInfo

    init(buildQueueInfo: BuildQueueInfo) {
        self.buildQueueInfo = buildQueueInfo
    }

    var totalSlots: Int {
        buildQueueInfo.totalSlots
    }

    var onHold: String {
        "On hold: \(buildQueueInfo.queuedBuilds)"
    }

    func slotIsFree(slotIndex: Int) -> Bool {
        slotIndex >= buildQueueInfo.runningBuilds
    }
}
