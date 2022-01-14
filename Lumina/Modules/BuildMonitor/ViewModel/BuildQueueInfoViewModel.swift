import SwiftUI
import BuildStatusChecker

class BuildQueueInfoViewModel: ObservableObject {
    let buildQueueInfo: BuildQueueInfo

    init(buildQueueInfo: BuildQueueInfo) {
        self.buildQueueInfo = buildQueueInfo
    }
    
    var totalAmount: Int {
        buildQueueInfo.totalSlots ?? 0
    }

    var usedAmount: Int {
        buildQueueInfo.runningBuilds
    }

    var runningText: String {
        "Running: \(buildQueueInfo.runningBuilds)"
    }

    var onHoldText: String {
        "On hold: \(buildQueueInfo.queuedBuilds)"
    }
    
    var canDisplayUsageBar: Bool {
        return buildQueueInfo.totalSlots != nil
    }

    var totalNumberOfConcurrenciesText: String {
        let totalSlots: String
            
        if let amount = buildQueueInfo.totalSlots {
            totalSlots = "\(amount)"
        }
        else {
            totalSlots = "Unknown"
        }
        
        return "Total number of concurrencies: \(totalSlots)"
    }

    var numberOfTotalSlotsKnown: Bool {
        buildQueueInfo.totalSlots != nil
    }

    func slotIsFree(slotIndex: Int) -> Bool {
        slotIndex >= buildQueueInfo.runningBuilds
    }
}
