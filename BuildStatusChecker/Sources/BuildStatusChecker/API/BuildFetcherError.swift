public enum BuildFetcherError: Error {
    case noNetworkConnection
    case requestFailed(message: String)
    case incompleteProviderConfiguration
}
