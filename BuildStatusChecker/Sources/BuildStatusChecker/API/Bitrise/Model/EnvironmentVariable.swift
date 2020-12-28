struct EnvironmentVariable: Codable {
    static let sourceBitriseBuildNumberKey = "SOURCE_BITRISE_BUILD_NUMBER"

    let key: String
    let value: String
}
