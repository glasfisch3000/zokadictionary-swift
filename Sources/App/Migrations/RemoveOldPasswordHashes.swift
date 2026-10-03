import Fluent
import FluentPostgresDriver

struct RemoveOldPasswordHashes: AsyncMigration {
    func prepare(on database: any Database) async throws {
		try await database.schema("users")
			.deleteField("password")
			.deleteField("salt")
			.update()
    }
    
    func revert(on database: any Database) async throws {
		try await database.schema("users")
			.field("password", .string)
			.field("salt", .uuid)
			.update()
    }
}
