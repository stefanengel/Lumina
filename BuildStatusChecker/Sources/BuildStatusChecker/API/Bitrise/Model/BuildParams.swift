public struct BuildParams: Codable {
    let branch: String?
    let branchDest: String?
    let branchDestRepoOwner: String?
    let branchRepoOwner: String?
    let buildRequestSlug: String?
    let commitHash: String?
    let commitMessage: String?
    let commitPaths: [CommitPath]?
    let diffUrl: String?
    // Environments is the only property that needs to be converted
    // when there BuildParams shoulkd be used to retrigger a build
    // https://devcenter.bitrise.io/api/build-trigger/#specifying-environment-variables
    let environments: [[String: String]]?
    let pullRequestAuthor: String?
    let pullRequestHeadBranch: String?
    let pullRequestId: Int?
    let pullRequestMergeBranch: String?
    let pullRequestRepositoryUrl: String?
    let skipGitStatusReport: Bool?
    let tag: String?
    let workflowId: String?

    public var sourceBitriseBuildNumber: Int? {
        guard let environments = environments else { return nil }

        let sourceBitriseBuildNumberKey = "SOURCE_BITRISE_BUILD_NUMBER"

        #warning("This is horrible, but the JSON structure is crappy")
        // "environments": [{
        //  "value": "24572",
        //  "key": "SOURCE_BITRISE_BUILD_NUMBER"
        // }],
        for dict in environments {
            if dict.values.contains(sourceBitriseBuildNumberKey), let numberString = dict["value"] {
                return Int(numberString)
            }
        }

        return nil
    }
}

// MARK: - GenericBuildParams
extension BuildParams: GenericBuildParams {
    public func asCodable() -> Codable {
        self
    }
}
