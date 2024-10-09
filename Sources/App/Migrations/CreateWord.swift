import Fluent

struct CreateWord: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let wordType = try await database.enum("word_type")
            .case("adjective")
            .case("noun")
            .case("number")
            .case("particle")
            .case("preposition")
            .case("questionWord")
            .case("verb")
            .create()
        
        try await database.schema("words")
            .id()
            .field("string", .string, .required)
            .field("description", .string)
            .field("type", wordType, .required)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("words")
            .delete()
        
        try await database.enum("word_type")
            .delete()
    }
}
