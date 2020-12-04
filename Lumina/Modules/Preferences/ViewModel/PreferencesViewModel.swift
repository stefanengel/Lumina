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
    @Published var groupByBuildNumber: Bool = false
    @Published var disableSeasonalDecorations: Bool = false

    private var settings: SettingsStoreProtocol = SettingsStore()
    private let bitrise: BitriseStore = BitriseStore()

    init() {
        updateIntervalInSeconds = settings.readUpdateInterval()
        masterBranchName = settings.read(setting: .masterBranchName)
        developBranchName = settings.read(setting: .developBranchName)
        featureBranchPrefix = settings.read(setting: .featureBranchPrefix)
        releaseBranchPrefix = settings.read(setting: .releaseBranchPrefix)
        hotfixBranchPrefix = settings.read(setting: .hotfixBranchPrefix)
        disableSeasonalDecorations = settings.disableSeasonalDecorations

        ignoreList = Set(settings.readBranchIgnoreList().map{ IgnorePattern(pattern: $0) })
        workflowList = Set(bitrise.readWorkflowList())

        bitriseBaseUrl = bitrise.read(setting: .bitriseBaseUrl)
        bitriseAuthToken = bitrise.read(setting: .bitriseAuthToken)
        bitriseAppSlug = bitrise.read(setting: .bitriseAppSlug)
        groupByBuildNumber = bitrise.groupByBuildNumber
    }

    func saveProvider(bitriseBaseUrl: String, bitriseAuthToken: String, bitriseAppSlug: String) {
    }

    func saveSettings() {
        settings.store(updateInterval: updateIntervalInSeconds)
        settings.disableSeasonalDecorations = disableSeasonalDecorations
        settings.store(value: masterBranchName, for: .masterBranchName)
        settings.store(value: developBranchName, for: .developBranchName)
        settings.store(value: featureBranchPrefix, for: .featureBranchPrefix)
        settings.store(value: releaseBranchPrefix, for: .releaseBranchPrefix)
        settings.store(value: hotfixBranchPrefix, for: .hotfixBranchPrefix)
        settings.store(value: hotfixBranchPrefix, for: .hotfixBranchPrefix)

        settings.store(branchIgnoreList: ignoreList.map { $0.pattern })
        bitrise.store(workflowList: Array(workflowList))

        bitrise.store(setting: .bitriseBaseUrl, value: bitriseBaseUrl)
        bitrise.store(setting: .bitriseAuthToken, value: bitriseAuthToken)
        bitrise.store(setting: .bitriseAppSlug, value: bitriseAppSlug)
        bitrise.groupByBuildNumber = groupByBuildNumber
    }

    private func updateFromStore() {

    }

    private func parse(ignoreList: String) -> [String] {
        return ignoreList.replacingOccurrences(of: " ", with: "").components(separatedBy: ",")
    }
}
