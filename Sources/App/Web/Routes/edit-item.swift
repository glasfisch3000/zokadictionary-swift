import Vapor
import Fluent

extension WebRoutes {
	func getEditItem(req: Request) async throws -> View {
		struct Context: Encodable {
			var user: Identified<User.DTO>
			var `return`: String
			var word: Identified<Word.DTOWithIdentifiedRelations>
		}
		
		guard let wordID = req.parameters.get("wordID", as: UUID.self) else {
			throw WebError.malformedRequest
		}
		
		guard let word = try await Word
			.query(on: req.db)
			.filter(\.$id == wordID)
			.with(\.$translations)
			.with(\.$references, {
				$0.with(\.$destination)
			})
			.first() else {
			throw WebError.notFound
		}
		
		let user = try req.auth.require(User.self)
		let returnPath = try req.query.get(String?.self, at: "return")
		
		let context = Context(
			user: try user.toDTO(),
			return: returnPath ?? "/",
			word: try word.toDTOWithIdentifiedRelations()
		)
		
		return try await req.view.render("Pages/edit-item", context)
	}
	
	func postEditItem(req: Request) async throws -> Bool {
		struct DTO: Codable {
			var string: String
			var type: Word.WordType
			var translations: [Translation.DTO]
			var references: [Reference.DTO]
		}
		
		guard let wordID = req.parameters.get("wordID", as: UUID.self) else {
			throw WebError.malformedRequest
		}
		
		guard let word = try await Word.find(wordID, on: req.db) else {
			throw WebError.notFound
		}
		
		try req.auth.require(User.self)
		let dto = try req.content.decode(DTO.self)
		
		if dto.string.isEmpty {
			return false
		}
		
		try await req.db.transaction { db in
			word.string = dto.string
			word.type = dto.type
			try await word.update(on: db)
			
			try await word.translations.delete(on: db)
			try await word.references.delete(on: db)
			
			let translations = dto.translations.map {
				Translation(translation: $0.translation, comment: $0.comment.flatMap { $0.isEmpty ? nil : $0 }, wordID: wordID)
			}
			try await translations.create(on: db)
			
			let references = dto.references.map {
				Reference(sourceID: wordID, destinationID: $0.destinationID, comment: $0.comment.flatMap { $0.isEmpty ? nil : $0 })
			}
			try await references.create(on: db)
		}
		
		return true
	}
}
