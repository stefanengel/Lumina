import Foundation

public class SettingsStore: SettingsStoreProtocol {
    let defaults = UserDefaults.standard

    private let updateIntervalKey = "updateInterval"
    private let branchIgnoreListKey = "branchIgnoreList"

    public init() {}

    public func read(setting: BranchSetting) -> String {
        defaults.string(forKey: setting.rawValue) ?? setting.defaultValue
    }

    public func store(value: String , for setting: BranchSetting) {
        defaults.set(value, forKey: setting.rawValue)
    }

    public func readBranchIgnoreList() -> [String] {
       return defaults.stringArray(forKey: branchIgnoreListKey) ?? []
    }

    public func store(branchIgnoreList: [String]) {
        defaults.set(branchIgnoreList, forKey: branchIgnoreListKey)
    }

    public func readUpdateInterval() -> Int {
        defaults.integer(forKey: updateIntervalKey)
    }

    public func store(updateInterval: Int) {
        defaults.set(updateInterval, forKey: updateIntervalKey)
    }
}
