import Foundation

@propertyWrapper
public struct Storage<T: Codable> {
    private let key: String
    private let `default`: T
    private let userDefaults: UserDefaults?

    private var lastRetrievedValue: T?

    public init(key: String, default: T, userDefaults: UserDefaults? = .standard) {
        self.key = key
        self.default = `default`
        self.userDefaults = userDefaults
    }

    public var wrappedValue: T {
        get {
            if let lastRetrievedValue {
                return lastRetrievedValue
            }

            guard let data = userDefaults?.object(forKey: key) as? Data else {
                return `default`
            }

            let value = try? JSONDecoder().decode(T.self, from: data)
            return value ?? `default`
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            userDefaults?.set(data, forKey: key)
            lastRetrievedValue = newValue
        }
    }
}
