import ArgumentParser
import Vapor

enum ParsableEnvironment: String, ExpressibleByArgument {
    case production
    case development
    case testing
    
    func makeEnvironment() -> Environment {
        switch self {
        case .production: .production
        case .development: .development
        case .testing: .testing
        }
    }
}
