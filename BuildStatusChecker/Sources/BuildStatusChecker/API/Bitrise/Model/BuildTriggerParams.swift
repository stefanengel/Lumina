import Foundation

// These are the build params that bitrise needs to trigger a build. The are mostly identitcal to OriginalBuildParams but `environments` has a different structure.
public struct BuildTriggerParams: Codable {
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
    let environments: [BuildTriggerEnvironmentVariable]?
    let pullRequestAuthor: String?
    let pullRequestHeadBranch: String?
    let pullRequestId: String?
    let pullRequestMergeBranch: String?
    let pullRequestRepositoryUrl: String?
    let skipGitStatusReport: Bool?
    let tag: String?
    let workflowId: String?
}
