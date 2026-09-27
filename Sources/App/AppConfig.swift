import typealias Foundation.TimeInterval
import Vapor
import FluentPostgresDriver

struct AppConfig: Sendable {
	var databaseHost: String
	var databasePort: Int
	var databaseName: String
	var databaseUsername: String
	var databasePassword: String
	
	var sessionLifetime: TimeInterval
	
	var adminUsername: String
	var adminPassword: String
	
	static let global: Self = {
		AppConfig(
			databaseHost: Environment.get("DATABASE_HOST") ?? "localhost",
			databasePort: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
			databaseName: Environment.get("DATABASE_NAME") ?? "vapor_database",
			databaseUsername: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
			databasePassword: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
			sessionLifetime: Environment.get("SESSION_LIFETIME").flatMap(TimeInterval.init(_:)) ?? 60*60*24*7, // 7 days by default
			adminUsername: Environment.get("ADMIN_USERNAME") ?? "admin",
			adminPassword: Environment.get("ADMIN_PASSWORD") ?? "admin",
		)
	}()
}
