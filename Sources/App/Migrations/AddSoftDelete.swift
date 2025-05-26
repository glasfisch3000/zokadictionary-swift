import Fluent

struct AddSoftDelete: AsyncMigration {
	func prepare(on database: any Database) async throws {
		try await database.schema("words")
			.field("deleted_at", .datetime)
			.update()
		
		try await database.schema("translations")
			.field("deleted_at", .datetime)
			.update()
		
		try await database.schema("references")
			.field("deleted_at", .datetime)
			.update()
	}
	
	func revert(on database: any Database) async throws {
		try await database.schema("words")
			.deleteField("deleted_at")
			.update()
		
		try await database.schema("translations")
			.deleteField("deleted_at")
			.update()
		
		try await database.schema("references")
			.deleteField("deleted_at")
			.update()
	}
}
