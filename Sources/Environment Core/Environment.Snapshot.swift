extension Environment {

    public struct Snapshot: Sendable, Hashable {

        public var values: [Swift.String: Swift.String]
    }
}

extension Environment.Snapshot {

    public init() {
        self.values = [:]
    }

    public init(_ values: [Swift.String: Swift.String]) {
        self.values = values
    }
}

extension Environment.Snapshot {

    public subscript(name: Swift.String) -> Swift.String? {
        get { values[name] }
        set { values[name] = newValue }
    }
}

extension Environment.Snapshot {

    public init(_ dotenv: Environment.Dotenv) {
        self.init(dotenv.values)
    }
}

extension Environment.Snapshot {

    public func string(_ key: Swift.String) -> Swift.String? {
        self[key]
    }

    public func int(_ key: Swift.String) -> Swift.Int? {
        self[key].flatMap(Swift.Int.init)
    }

    public func bool(_ key: Swift.String) -> Swift.Bool? {
        guard let value = self[key]?.lowercased() else { return nil }
        switch value {
        case "1", "true", "yes", "on": return true
        case "0", "false", "no", "off": return false
        default: return nil
        }
    }

    public func url(_ key: Swift.String) -> Swift.String? {
        self[key]
    }
}
