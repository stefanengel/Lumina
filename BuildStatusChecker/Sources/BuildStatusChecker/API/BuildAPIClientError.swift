public enum BuildAPIClientError: Error {
    case noNetworkConnection
    case requestFailed(message: String)
    case incompleteProviderConfiguration
    case organizationNotFound
}
