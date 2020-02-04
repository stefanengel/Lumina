import KeychainSwift

public class BitriseStore {
    private let keychain = KeychainSwift()

    public init() {}

    public func read(setting: BitriseSetting) -> String {
        keychain.get(setting.rawValue) ?? ""
    }

    public func store(setting: BitriseSetting, value: String) {
        keychain.set(value, forKey: setting.rawValue)
    }
}
