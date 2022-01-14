import Foundation
import KeychainSwift

public class BitriseStore {
    private let keychain = KeychainSwift(keyPrefix: "luminaTestKey_")
    private let defaults = UserDefaults.standard

    public init() {}
}

// MARK: - BitriseStoreProtocol
extension BitriseStore: BitriseStoreProtocol {
    public var configuration: BitriseConfiguration {
        get {
            BitriseConfiguration(
                authToken: authToken,
                baseUrl: baseUrl,
                appSlug: appSlug,
                orgSlug: orgSlug
            )
        }
        set {
            authToken = newValue.authToken
            baseUrl = newValue.baseUrl
            appSlug = newValue.appSlug
            orgSlug = newValue.orgSlug
        }
    }
}

// MARK: - Settings
extension BitriseStore {
    var authToken: String {
        get {
            read(setting: .bitriseAuthToken)
        }
        set {
            store(setting: .bitriseAuthToken, value: newValue)
        }
    }

    var baseUrl: String {
        get {
            read(setting: .bitriseBaseUrl)
        }
        set {
            store(setting: .bitriseBaseUrl, value: newValue)
        }
    }

    var appSlug: String {
        get {
            read(setting: .bitriseAppSlug)
        }
        set {
            store(setting: .bitriseAppSlug, value: newValue)
        }
    }

    var orgSlug: String {
        get {
            read(setting: .bitriseOrgSlug)
        }
        set {
            store(setting: .bitriseOrgSlug, value: newValue)
        }
    }
}

// MARK: - General keychain access
extension BitriseStore {
    func read(setting: BitriseSetting) -> String {
        keychain.get(setting.rawValue) ?? ""
    }

    func store(setting: BitriseSetting, value: String) {
        keychain.set(value, forKey: setting.rawValue)
    }
}
