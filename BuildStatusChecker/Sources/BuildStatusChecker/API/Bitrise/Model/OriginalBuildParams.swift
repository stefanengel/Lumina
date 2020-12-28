import Foundation

// These are the build parameters that bitrise reports for the build
public struct OriginalBuildParams: Codable {
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
    let environments: [OriginalEnvironmentVariable]?
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
            if variable.key == OriginalEnvironmentVariable.sourceBitriseBuildNumberKey {
                return Int(variable.value)
            }
        }

        return nil
    }
}
// MARK: Convert to BuildTriggerParams that can be used to start the exact same build again
extension OriginalBuildParams {
    var asBuildTriggerParams: BuildTriggerParams {
        var buildTriggerEnvironments = [BuildTriggerEnvironmentVariable]()

        if let environments = environments {
            for variable in environments {
                buildTriggerEnvironments.append(variable.asBuildTriggerEnvironmentVariable)
            }
        }

        return BuildTriggerParams(
            branch: branch,
            branchDest: branchDest,
            branchDestRepoOwner: branchRepoOwner,
            branchRepoOwner: branchRepoOwner,
            buildRequestSlug: buildRequestSlug,
            commitHash: commitHash,
            commitMessage: commitMessage,
            commitPaths: commitPaths,
            diffUrl: diffUrl,
            environments: buildTriggerEnvironments,
            pullRequestAuthor: pullRequestAuthor,
            pullRequestHeadBranch: pullRequestHeadBranch,
            pullRequestId: pullRequestId,
            pullRequestMergeBranch: pullRequestMergeBranch,
            pullRequestRepositoryUrl: pullRequestRepositoryUrl,
            skipGitStatusReport: skipGitStatusReport,
            tag: tag,
            workflowId: workflowId
        )
    }
}


// MARK: - GenericBuildParams
extension OriginalBuildParams: GenericBuildParams {
    public var asJSONEncodedHTTPBody: Data {
        let body = BuildTriggerBody(buildParams: asBuildTriggerParams)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return try! encoder.encode(body)
    }
}
