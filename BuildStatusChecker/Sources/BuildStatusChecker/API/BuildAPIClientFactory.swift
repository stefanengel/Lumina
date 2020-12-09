public class BuildAPIClientFactory {
    static public func createBuildAPI() -> BuildAPIClient {
        // for now, there is only support for Bitrise
        return BitriseAPIClient()
    }
}
