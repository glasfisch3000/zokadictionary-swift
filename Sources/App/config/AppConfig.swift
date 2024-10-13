import Vapor

public struct AppConfig: Codable {
    var environment: ParsableEnvironment = .development
    var databaseURL: URL
}
