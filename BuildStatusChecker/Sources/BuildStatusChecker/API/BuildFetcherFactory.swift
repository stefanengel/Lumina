public class BuildFetcherFactory {
    static public func createBuildFetcher() -> BuildFetcher {
        // for now, there is only support for Bitrise
        return BitriseBuildFetcher()
    }
}
