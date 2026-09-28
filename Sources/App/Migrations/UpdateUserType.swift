import Fluent

struct UpdateUserType: AsyncMigration {
    func prepare(on database: any Database) async throws {
        _ = try await database.enum("user_type")
            .deleteCase("maintainer")
			.case("contributor")
			.case("admin")
            .update()
		
		if try await database.query(User.self).count() == 0 {
			// no users yet, create admin user
			let user = User(
				name: AppConfig.global.adminUsername,
				type: .admin,
				salt: .init(),
				password: AppConfig.global.adminPassword,
			)
			try await user.create(on: database)
		}
    }
    
    func revert(on database: any Database) async throws {
        _ = try await database.enum("user_type")
			.case("maintainer")
			.deleteCase("contributor")
			.deleteCase("admin")
			.update()
    }
}
