import BuildStatusChecker

struct SettingsMock {
    static let settings = Settings(
        developBranchName: "develop",
        masterBranchName: "master",
        releaseBranchPrefix: "release",
        hotfixBranchPrefix: "hotfix",
        featureBranchPrefix: "feature",
        disableSeasonalDecorations: false,
        branchIgnoreList: [],
        updateIntervalInSeconds: 60,
        workflowList: [],
        groupByBuildNumber: true
    )
}
