import Fluent

struct CreateReference: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("references")
            .id()
            .field("source_id", .uuid, .required, .references("words", "id", onDelete: .cascade))
            .field("destination_id", .uuid, .required, .references("words", "id", onDelete: .cascade))
            .field("comment", .string)
            .unique(on: "source_id", "destination_id", name: "source_destination")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("references")
            .delete()
    }
}
