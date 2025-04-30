import Fluent

struct UniqueUsername: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("users")
            .unique(on: "username")
            .update()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("users")
            .deleteUnique(on: "username")
            .update()
    }
}
