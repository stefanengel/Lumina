import os.log

extension OSLog {
    private static var subsystem = "biz.stefanengel.BuildStatusChecker"

    static let buildFetcher = OSLog(subsystem: subsystem, category: "buildFetcher")
    static let builds = OSLog(subsystem: subsystem, category: "builds")
    static let request = OSLog(subsystem: subsystem, category: "request")
}
