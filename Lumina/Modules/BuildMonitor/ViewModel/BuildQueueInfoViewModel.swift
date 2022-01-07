import SwiftUI
import BuildStatusChecker

class BuildQueueInfoViewModel: ObservableObject {
    let buildQueueInfo: BuildQueueInfo

    init(buildQueueInfo: BuildQueueInfo) {
        self.buildQueueInfo = buildQueueInfo
    }

    var totalSlots: Int {
        buildQueueInfo.totalSlots ?? 0
    }

    var onHoldText: String {
        "On hold: \(buildQueueInfo.queuedBuilds)"
    }

    var numberOfTotalSlotsUnknownText: String {
        "Number of concurrencies is unknown, currently running: \(buildQueueInfo.runningBuilds), on hold: \(buildQueueInfo.queuedBuilds)"
    }

    var numberOfTotalSlotsKnown: Bool {
        buildQueueInfo.totalSlots != nil
    }

    func slotIsFree(slotIndex: Int) -> Bool {
        slotIndex >= buildQueueInfo.runningBuilds
    }
}
