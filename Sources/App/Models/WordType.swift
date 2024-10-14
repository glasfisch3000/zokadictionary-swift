import ArgumentParser

enum WordType: String, Sendable, Hashable, Codable, ExpressibleByArgument {
    case adjective
    case noun
    case number
    case particle
    case preposition
    case questionWord
    case verb
}
