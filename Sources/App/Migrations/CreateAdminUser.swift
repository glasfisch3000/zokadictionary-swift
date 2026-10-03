import Fluent

struct CreateAdminUser: AsyncMigration {
	func prepare(on database: any Database) async throws {
		guard try await database.query(User.self).count() == 0 else {
			return
		}
		
		// no users yet, create admin user
		let user = try await User(
			name: AppConfig.global.adminUsername,
			type: User.UserType.admin,
			password: AppConfig.global.adminPassword,
		)
		try await user.create(on: database)
	}
	
	func revert(on database: any Database) async throws { }
}
