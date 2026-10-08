import typealias Foundation.TimeInterval
import Vapor
import FluentPostgresDriver

struct AppConfig: Sendable {
	var database: DatabaseConfig
	
	var sessionLifetime: TimeInterval
	
	var adminUsername: String
	var adminPassword: String
	
	static let global: Self = {
		AppConfig(
			database: .global,
			sessionLifetime: Environment.get("SESSION_LIFETIME").flatMap(TimeInterval.init(_:)) ?? 60*60*24*7, // 7 days by default
			adminUsername: Environment.get("ADMIN_USERNAME") ?? "admin",
			adminPassword: Environment.get("ADMIN_PASSWORD") ?? "admin",
		)
	}()
}

extension AppConfig {
	struct DatabaseConfig: Sendable {
		var host: String
		var port: Int
		var username: String
		var password: String
		var database: String
		
		static let global: Self = {
			DatabaseConfig(
				host: Environment.get("DATABASE_HOST") ?? "localhost",
				port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
				username: Environment.get("DATABASE_USERNAME") ?? "zokadictionary",
				password: Environment.get("DATABASE_PASSWORD") ?? "zokadictionary",
				database: Environment.get("DATABASE_NAME") ?? "zokadictionary",
			)
		}()
	}
}
