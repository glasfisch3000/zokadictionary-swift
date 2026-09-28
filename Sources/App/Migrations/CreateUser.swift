import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let userType = try await database.enum("user_type")
            .case("viewer")
            .case("maintainer")
            .create()
        
        try await database.schema("users")
            .id()
            .field("username", .string, .required)
            .field("user_type", userType, .required)
            .field("salt", .uuid, .required)
            .field("password", .data, .required)
            .create()
		
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
        try await database.schema("users")
            .delete()
        
        try await database.enum("user_type")
            .delete()
    }
}
