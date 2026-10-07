import Vapor
import Fluent

extension WebRoutes {
	private struct NewItemRequestDTO: Decodable {
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
	
	func getNewItem(req: Request) async throws -> View {
		struct Context: Encodable {
			var user: Identified<User.DTO>
			var `return`: String
		}
		
		let user = try req.auth.require(User.self)
		guard user.type == .admin || user.type == .contributor else {
			throw WebError.forbidden
		}
		
		let returnPath = try req.query.get(String?.self, at: "return")
		
		let context = Context(
			user: try user.toDTO(),
			return: returnPath ?? "/"
		)
		
		return try await req.view.render("Pages/new-item", context)
	}
	
	func postNewItem(req: Request) async throws -> Bool {
		let user = try req.auth.require(User.self)
		guard user.type == .admin || user.type == .contributor else {
			throw WebError.forbidden
		}
		
		let dto = try req.content.decode(NewItemRequestDTO.self)
		guard let dto = dto.validate() else {
			return false
		}
		
		try await req.db.transaction { db in
			let word = Word(string: dto.string, type: dto.type)
			try await word.create(on: db)
			let wordID = try word.requireID()
			
			let translations = dto.translations.map { dto -> Translation in
				Translation(translation: dto.translation, comment: dto.comment.flatMap { $0.isEmpty ? nil : $0 }, wordID: wordID)
			}
			try await translations.create(on: db)
			
			let references = dto.references.map { dto -> Reference in
				Reference(sourceID: wordID, destinationID: dto.destinationID, comment: dto.comment.flatMap { $0.isEmpty ? nil : $0 })
			}
			try await references.create(on: db)
		}
		
		return true
	}
}
