import SwiftUI
import BuildStatusChecker

class PreferencesViewModel: ObservableObject {
    @Published var updateIntervalInSeconds: Int = 0
    @Published var masterBranchName: String = ""
    @Published var developBranchName: String = ""
    @Published var featureBranchPrefix: String = ""
    @Published var releaseBranchPrefix: String = ""
    @Published var hotfixBranchPrefix: String = ""
    @Published var newIgnoreSubstring: String = ""
    @Published var ignoreList: Set = Set<IgnorePattern>()
    @Published var newWorkflowString: String = ""
    @Published var workflowList: Set = Set<String>()

    @Published var bitriseBaseUrl: String = ""
    @Published var bitriseAuthToken: String = ""
    @Published var bitriseAppSlug: String = ""
    @Published var bitriseOrgSlug: String = ""
    @Published var groupByBuildNumber: Bool = false
    @Published var disableSeasonalDecorations: Bool = false

    private var settings = SettingsStore().settings
    private let bitrise = BitriseStore().configuration

    let defaultBitriseBaseUrl = "https://api.bitrise.io/v0.1/apps"

    init() {
        updateIntervalInSeconds = settings.updateIntervalInSeconds
        masterBranchName = settings.masterBranchName
        developBranchName = settings.developBranchName
        featureBranchPrefix = settings.featureBranchPrefix
        releaseBranchPrefix = settings.releaseBranchPrefix
        hotfixBranchPrefix = settings.hotfixBranchPrefix
        disableSeasonalDecorations = settings.disableSeasonalDecorations

        ignoreList = Set(settings.branchIgnoreList.map{ IgnorePattern(pattern: $0) })
        workflowList = Set(settings.workflowList)

        bitriseBaseUrl = bitrise.baseUrl
        bitriseAuthToken = bitrise.authToken
        bitriseAppSlug = bitrise.appSlug
        bitriseOrgSlug = bitrise.orgSlug
        groupByBuildNumber = settings.groupByBuildNumber

        if bitriseBaseUrl.isEmpty {
            bitriseBaseUrl = defaultBitriseBaseUrl
        }
    }

    func saveProvider(bitriseBaseUrl: String, bitriseAuthToken: String, bitriseAppSlug: String, bitriseOrgSlug: String) {
    }

    func saveSettings() {
        let updatedSettings = Settings(
            developBranchName: developBranchName,
            masterBranchName: masterBranchName,
            releaseBranchPrefix: releaseBranchPrefix,
            hotfixBranchPrefix: hotfixBranchPrefix,
            featureBranchPrefix: featureBranchPrefix,
            disableSeasonalDecorations: disableSeasonalDecorations,
            branchIgnoreList: ignoreList.map { $0.pattern },
            updateIntervalInSeconds: updateIntervalInSeconds,
            workflowList: Array(workflowList),
            groupByBuildNumber: groupByBuildNumber
        )

        SettingsStore().settings = updatedSettings

        let updatedConfig = BitriseConfiguration(
            authToken: bitriseAuthToken,
            baseUrl: bitriseBaseUrl,
            appSlug: bitriseAppSlug,
            orgSlug: bitriseOrgSlug
        )

        BitriseStore().configuration = updatedConfig
    }

    private func updateFromStore() {

    }

    private func parse(ignoreList: String) -> [String] {
        return ignoreList.replacingOccurrences(of: " ", with: "").components(separatedBy: ",")
    }
}
