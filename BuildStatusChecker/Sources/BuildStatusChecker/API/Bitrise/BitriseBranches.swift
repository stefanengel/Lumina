import Foundation
import os

public struct BitriseBranches: Codable {
    public let data: [String]

    public init() {
        data = []
    }
}

// MARK: - Finding specific branches
extension BitriseBranches {
    func findLatestBranch(withPrefix prefix: String) -> Branch? {
        return data
            .filter{ $0.starts(with: prefix) && hasVersionPostfix(branchName: $0) }
            .sorted { $0 > $1 }
            .first
    }
}

// MARK: - Checking for specific version pattern of prefixed branches
extension BitriseBranches {
    func hasVersionPostfix(branchName: String) -> Bool {
        let range = NSRange(location: 0, length: branchName.utf16.count)
        do {
            let regex = try NSRegularExpression(pattern: "[a-zA-Z]/\\d+.\\d+.\\d+")
            return regex.firstMatch(in: branchName, options: [], range: range) != nil
        } catch {
            os_log("Error building the regualar expression: %{PUBLIC}@", log: OSLog.buildFetcher, type: .error, error.localizedDescription)
            return false
        }
    }
}
