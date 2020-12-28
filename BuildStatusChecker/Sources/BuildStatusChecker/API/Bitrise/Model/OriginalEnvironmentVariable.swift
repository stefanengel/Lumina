struct OriginalEnvironmentVariable: Codable {
    static let sourceBitriseBuildNumberKey = "SOURCE_BITRISE_BUILD_NUMBER"

    let key: String
    let value: String
}

// MARK: - Converter for build trigger
extension OriginalEnvironmentVariable {
    var asBuildTriggerEnvironmentVariable: BuildTriggerEnvironmentVariable {
        BuildTriggerEnvironmentVariable(mappedTo: key, value: value)
    }
}
