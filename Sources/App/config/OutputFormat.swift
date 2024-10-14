import ArgumentParser

enum OutputFormat: String, Sendable, Hashable, Codable, ExpressibleByArgument {
    case json
    case yaml
}

struct StringEncodingError: Error, CustomStringConvertible {
    init() { }
    
    var description: String {
        "Custom string encoding failed."
    }
}
