import Fluent

struct UpdateUserType: AsyncMigration {
    func prepare(on database: any Database) async throws {
        _ = try await database.enum("user_type")
            .deleteCase("maintainer")
			.case("contributor")
			.case("admin")
            .update()
    }
    
    func revert(on database: any Database) async throws {
        _ = try await database.enum("user_type")
			.case("maintainer")
			.deleteCase("contributor")
			.deleteCase("admin")
			.update()
    }
}
