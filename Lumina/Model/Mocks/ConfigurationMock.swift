import BuildStatusChecker

struct ConfigurationMock {
    static let configuration = BitriseConfiguration(
        authToken: "authToken",
        baseUrl: "baseUrl",
        appSlug: "appSlug",
        orgSlug: "orgSlug"
    )
}
