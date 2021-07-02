import SwiftUI
import BuildStatusChecker

class BuildQueueInfoViewModel: ObservableObject {
    let buildQueueInfo: BuildQueueInfo

    init(buildQueueInfo: BuildQueueInfo) {
        self.buildQueueInfo = buildQueueInfo
    }

    var totalSlots: String {
        "Total build slots: \(buildQueueInfo.totalSlots)"
    }

    var running: String {
        "Running: \(buildQueueInfo.runningBuilds)"
    }

    var onHold: String {
        "On hold: \(buildQueueInfo.queuedBuilds)"
    }

    var backgroundColor: Color {
        buildQueueInfo.queuedBuilds > 0 ? Colors.alizarin : Colors.emerald
    }
}
