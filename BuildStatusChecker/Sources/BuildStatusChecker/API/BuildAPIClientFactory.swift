public class BuildAPIClientFactory {
    static public func createBuildAPI(settings: Settings, config: BitriseConfiguration) -> BuildAPIClient {
        // for now, there is only support for Bitrise
        return BitriseAPIClient(settings: settings, config: config)
    }
}
