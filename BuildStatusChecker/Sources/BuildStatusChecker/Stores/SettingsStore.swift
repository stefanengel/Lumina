import Foundation

public class SettingsStore: SettingsStoreProtocol {
    let defaults = UserDefaults.standard

    private let updateIntervalKey = "updateInterval"
    private let branchIgnoreListKey = "branchIgnoreList"
    private let disableSeasonalDecorationsKey = "disableSeasonalDecorations"

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
        let interval = defaults.integer(forKey: updateIntervalKey)

        guard interval > 0 else {
            return 60
        }

        return interval
    }

    public func store(updateInterval: Int) {
        defaults.set(updateInterval, forKey: updateIntervalKey)
    }

    public var disableSeasonalDecorations: Bool {
        get {
            defaults.bool(forKey: disableSeasonalDecorationsKey)
        }
        set {
            defaults.set(newValue, forKey: disableSeasonalDecorationsKey)
        }
    }
}
