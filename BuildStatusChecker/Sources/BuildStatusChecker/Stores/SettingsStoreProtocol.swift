public protocol SettingsStoreProtocol {
    func read(setting: BranchSetting) -> String
    func store(value: String , for setting: BranchSetting)
    func readBranchIgnoreList() -> [String]
    func store(branchIgnoreList: [String])

    func readUpdateInterval() -> Int
    func store(updateInterval: Int)

    var disableSeasonalDecorations: Bool { get set }
}
