import Foundation

public class SettingsStore {
    let defaults = UserDefaults.standard

    private let updateIntervalKey = "updateInterval"
    private let branchIgnoreListKey = "branchIgnoreList"
    private let disableSeasonalDecorationsKey = "disableSeasonalDecorations"
    private let workflowListKey = "workflowList"
    private let groupByBuildNumberKey = "groupByBuildNumber"

    public init() {}

    var disableSeasonalDecorations: Bool {
        get {
            defaults.bool(forKey: disableSeasonalDecorationsKey)
        }
        set {
            defaults.set(newValue, forKey: disableSeasonalDecorationsKey)
        }
    }

    var workflowList: [String] {
        get {
            return defaults.stringArray(forKey: workflowListKey) ?? []
        }
        set {
            defaults.set(newValue, forKey: workflowListKey)
        }
    }

    var groupByBuildNumber: Bool {
        get {
            defaults.bool(forKey: groupByBuildNumberKey)
        }
        set {
            defaults.set(newValue, forKey: groupByBuildNumberKey)
        }
    }

    func read(setting: BranchSetting) -> String {
        defaults.string(forKey: setting.rawValue) ?? setting.defaultValue
    }

    func store(value: String , for setting: BranchSetting) {
        defaults.set(value, forKey: setting.rawValue)
    }

    func readBranchIgnoreList() -> [String] {
       return defaults.stringArray(forKey: branchIgnoreListKey) ?? []
    }

    func store(branchIgnoreList: [String]) {
        defaults.set(branchIgnoreList, forKey: branchIgnoreListKey)
    }

    func readUpdateInterval() -> Int {
        let interval = defaults.integer(forKey: updateIntervalKey)

        guard interval > 0 else {
            return 60
        }

        return interval
    }

    func store(updateInterval: Int) {
        defaults.set(updateInterval, forKey: updateIntervalKey)
    }
}

// MARK: - SettingsStoreProtocol
extension SettingsStore: SettingsStoreProtocol {
    public var settings: Settings {
        get {
            Settings(
                developBranchName: read(setting: .developBranchName),
                masterBranchName: read(setting: .masterBranchName),
                releaseBranchPrefix: read(setting: .releaseBranchPrefix),
                hotfixBranchPrefix: read(setting: .hotfixBranchPrefix),
                featureBranchPrefix: read(setting: .featureBranchPrefix),
                disableSeasonalDecorations: disableSeasonalDecorations,
                branchIgnoreList: readBranchIgnoreList(),
                updateIntervalInSeconds: readUpdateInterval(),
                workflowList: workflowList,
                groupByBuildNumber: groupByBuildNumber
            )
        }
        set {
            store(value: newValue.developBranchName, for: .developBranchName)
            store(value: newValue.masterBranchName, for: .masterBranchName)
            store(value: newValue.releaseBranchPrefix, for: .releaseBranchPrefix)
            store(value: newValue.hotfixBranchPrefix, for: .hotfixBranchPrefix)
            store(value: newValue.featureBranchPrefix, for: .featureBranchPrefix)
            disableSeasonalDecorations = newValue.disableSeasonalDecorations
            store(branchIgnoreList: newValue.branchIgnoreList)
            store(updateInterval: newValue.updateIntervalInSeconds)
            workflowList = newValue.workflowList
            groupByBuildNumber = newValue.groupByBuildNumber
        }
    }
}
