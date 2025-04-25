import ArgumentParser

enum UserType: String, Sendable, Hashable, Codable, ExpressibleByArgument {
    case viewer
    case maintainer
}
