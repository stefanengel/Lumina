import Foundation
import KeychainSwift

public class BitriseStore {
    private let keychain = KeychainSwift()
    private let defaults = UserDefaults.standard
    private let workflowListKey = "workflowList"

    public init() {}

    public func read(setting: BitriseSetting) -> String {
        keychain.get(setting.rawValue) ?? ""
    }

    public func store(setting: BitriseSetting, value: String) {
        keychain.set(value, forKey: setting.rawValue)
    }

    public func readWorkflowList() -> [String] {
        return defaults.stringArray(forKey: workflowListKey) ?? []
    }

    public func store(workflowList: [String]) {
        defaults.set(workflowList, forKey: workflowListKey)
    }
}
