import Vapor
import Fluent

extension WebRoutes {
	func getNewItem(req: Request) async throws -> View {
		struct Context: Encodable {
			var user: Identified<User.DTO>
			var `return`: String
		}
		
		let user = try req.auth.require(User.self)
		let returnPath = try req.query.get(String?.self, at: "return")
		
		let context = Context(
			user: try user.toDTO(),
			return: returnPath ?? "/"
		)
		
		return try await req.view.render("Pages/new-item", context)
	}
	
	func postNewItem(req: Request) async throws -> Bool {
		struct DTO: Codable {
			var string: String
			var type: Word.WordType
			var translations: [Translation.DTO]
			var references: [Reference.DTO]
		}
		
		let user = try req.auth.require(User.self)
		let dto = try req.content.decode(DTO.self)
		
		try await req.db.transaction { db in
			let word = Word(string: dto.string, type: dto.type)
			try await word.create(on: db)
			let wordID = try word.requireID()
			
			let translations = dto.translations.map {
				Translation(translation: $0.translation, comment: $0.comment, wordID: wordID)
			}
			try await translations.create(on: db)
			
			let references = dto.references.map {
				Reference(sourceID: wordID, destinationID: $0.destinationID, comment: $0.comment)
			}
			try await references.create(on: db)
		}
		
		return true
	}
}
