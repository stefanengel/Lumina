public struct BuildQueueInfo {
    public let totalSlots: Int
    public let runningBuilds: Int
    public let queuedBuilds: Int

    var description: String {
        "Total: \(totalSlots) / Running: \(runningBuilds) / Queued: \(queuedBuilds) "
    }
}
