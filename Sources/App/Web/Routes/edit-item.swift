import Vapor
import Fluent

extension WebRoutes {
	private struct EditItemRequestDTO: Decodable {
		var string: String
		var type: Word.WordType
		var translations: [Translation.DTO]
		var references: [Reference.DTO]
		
		func validate() -> Self? {
			var dto = self
			
			guard Word.validate(string: &dto.string) else {
				return nil
			}
			
			for case(let index, var item) in dto.translations.indexed() {
				guard item.validate() else {
					return nil
				}
				
				dto.translations[index] = item
			}
			for case(let index, var item) in dto.references.indexed() {
				guard item.validate() else {
					return nil
				}
				
				dto.references[index] = item
			}
			
			return dto
		}
	}
	
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
			.filter(\Word.$id == wordID)
			.with(\Word.$translations)
			.with(\Word.$references, {
				$0.with(\Reference.$destination)
			})
			.filter(Reference.self, \Reference.destination.$deleted != nil)
			.first() else {
			throw WebError.notFound
		}
		
		let user = try req.auth.require(User.self)
		guard user.type == .admin || user.type == .contributor else {
			throw WebError.forbidden
		}
		
		let returnPath = try req.query.get(String?.self, at: "return")
		
		let context = Context(
			user: try user.toDTO(),
			return: returnPath ?? "/",
			word: try word.toDTOWithIdentifiedRelations()
		)
		
		return try await req.view.render("Pages/edit-item", context)
	}
	
	func postEditItem(req: Request) async throws -> Bool {
		guard let wordID = req.parameters.get("wordID", as: UUID.self) else {
			throw WebError.malformedRequest
		}
		
		guard let word = try await Word.find(wordID, on: req.db) else {
			throw WebError.notFound
		}
		
		let user = try req.auth.require(User.self)
		guard user.type == .admin || user.type == .contributor else {
			throw WebError.forbidden
		}
		
		let dto = try req.content.decode(EditItemRequestDTO.self)
		guard let dto = dto.validate() else {
			return false
		}
		
		try await req.db.transaction { db in
			word.string = dto.string
			word.type = dto.type
			try await word.update(on: db)
			
			try await Translation
				.query(on: db)
				.filter(\.$word.$id == wordID)
				.delete()
			
			try await Reference
				.query(on: db)
				.with(\.$destination)
				.filter(\.$source.$id == wordID)
				.filter(\.destination.$deleted != nil)
				.delete()
			
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
