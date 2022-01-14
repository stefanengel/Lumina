public struct BuildQueueInfo {
    public let totalSlots: Int?
    public let runningBuilds: Int
    public let queuedBuilds: Int

    public init(totalSlots: Int?, runningBuilds: Int, queuedBuilds: Int) {
        self.totalSlots = totalSlots
        self.runningBuilds = runningBuilds
        self.queuedBuilds = queuedBuilds
    }

    var description: String {
        "Total: \(totalSlots) / Running: \(runningBuilds) / Queued: \(queuedBuilds) "
    }
}
