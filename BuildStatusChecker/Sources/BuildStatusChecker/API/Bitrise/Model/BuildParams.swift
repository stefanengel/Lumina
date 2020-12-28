import Foundation

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
    // when there BuildParams should be used to retrigger a build
    // https://devcenter.bitrise.io/api/build-trigger/#specifying-environment-variables
    let environments: [EnvironmentVariable]?
    let pullRequestAuthor: String?
    let pullRequestHeadBranch: String?
    let pullRequestId: String?
    let pullRequestMergeBranch: String?
    let pullRequestRepositoryUrl: String?
    let skipGitStatusReport: Bool?
    let tag: String?
    let workflowId: String?

    public var sourceBitriseBuildNumber: Int? {
        guard let environments = environments else { return nil }

        // "environments": [{
        //  "value": "24572",
        //  "key": "SOURCE_BITRISE_BUILD_NUMBER"
        // }],
        for variable in environments {
            if variable.key == EnvironmentVariable.sourceBitriseBuildNumberKey {
                return Int(variable.value)
            }
        }

        return nil
    }
}

// MARK: - GenericBuildParams
extension BuildParams: GenericBuildParams {
    public var asJSONEncodedHTTPBody: Data {
        try! JSONEncoder().encode(self)
    }
}
