public struct Settings {
    public let developBranchName: String
    public let masterBranchName: String
    public let releaseBranchPrefix: String
    public let hotfixBranchPrefix: String
    public let featureBranchPrefix: String
    public let disableSeasonalDecorations: Bool
    public let branchIgnoreList: [String]
    public let updateIntervalInSeconds: Int
    public let workflowList: [String]
    public let groupByBuildNumber: Bool

    public init(
        developBranchName: String,
        masterBranchName: String,
        releaseBranchPrefix: String,
        hotfixBranchPrefix: String,
        featureBranchPrefix: String,
        disableSeasonalDecorations: Bool,
        branchIgnoreList: [String],
        updateIntervalInSeconds: Int,
        workflowList: [String],
        groupByBuildNumber: Bool)
    {
        self.developBranchName = developBranchName
        self.masterBranchName = masterBranchName
        self.releaseBranchPrefix = releaseBranchPrefix
        self.hotfixBranchPrefix = hotfixBranchPrefix
        self.featureBranchPrefix = featureBranchPrefix
        self.disableSeasonalDecorations = disableSeasonalDecorations
        self.branchIgnoreList = branchIgnoreList
        self.updateIntervalInSeconds = updateIntervalInSeconds
        self.workflowList = workflowList
        self.groupByBuildNumber = groupByBuildNumber
    }
}
