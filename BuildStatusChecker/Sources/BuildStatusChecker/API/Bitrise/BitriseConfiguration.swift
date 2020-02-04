class BitriseConfiguration {
    private let bitrise = BitriseStore()

    public lazy var authToken: String = {
        return bitrise.read(setting: .bitriseAuthToken)
    }()
    public lazy var baseUrl: String = {
        return bitrise.read(setting: .bitriseBaseUrl)
    }()
    public lazy var appSlug: String = {
        return bitrise.read(setting: .bitriseAppSlug)
    }()

    public var isComplete: Bool {
        return !authToken.isEmpty && !baseUrl.isEmpty && !appSlug.isEmpty
    }
}
