import Fluent

struct CreateTranslation: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("translations")
            .id()
            .field("word_id", .uuid, .required, .references("words", "id", onDelete: .cascade))
            .field("translation", .string, .required)
            .field("comment", .string)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("translations")
            .delete()
    }
}
