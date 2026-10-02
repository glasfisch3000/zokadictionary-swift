import Fluent

struct AddArgon2PasswordHashing: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("users")
			.field("password_hash_argon2", .string)
            .update()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("users")
			.deleteField("password_hash_argon2")
			.update()
    }
}
