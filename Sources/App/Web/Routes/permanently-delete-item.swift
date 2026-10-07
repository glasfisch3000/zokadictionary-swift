import Vapor
import Fluent

extension WebRoutes {
	private struct PermanentlyDeleteItemContext: Encodable {
		var user: Identified<User.DTO>
		var `return`: String
		var word: Identified<Word.DTOWithIdentifiedRelations>
		var success: Bool
	}
	
	private func query(wordID: Word.IDValue, on db: any Database) -> QueryBuilder<Word> {
		Word.query(on: db)
			.withDeleted()
			.filter(\.$deleted != nil)
			.filter(\.$id == wordID)
			.with(\.$translations, withDeleted: true)
			.with(\.$references, withDeleted: true, {
				$0.with(\.$destination, withDeleted: true)
			})
			.with(\.$backReferences, withDeleted: true, {
				$0.with(\.$source, withDeleted: true)
			})
	}
	
	func getPermanentlyDeleteItem(req: Request) async throws -> View {
		guard let wordID = req.parameters.get("wordID", as: UUID.self) else {
			throw WebError.malformedRequest
		}
		
		let user = try req.auth.require(User.self)
		guard user.type == .admin || user.type == .contributor else {
			throw WebError.forbidden
		}
		
		guard let word = try await query(wordID: wordID, on: req.db).first() else {
			throw WebError.notFound
		}
		
		let returnPath = try req.query.get(String?.self, at: "return")
		let dto = try word.toDTOWithIdentifiedRelations()
		
		return try await renderParmanentlyDeleteItem(word: dto, return: returnPath, user: user, req: req)
	}
	
	func postPermanentlyDeleteItem(req: Request) async throws -> View {
		guard let wordID = req.parameters.get("wordID", as: UUID.self) else {
			throw WebError.malformedRequest
		}
		
		let user = try req.auth.require(User.self)
		guard user.type == .admin || user.type == .contributor else {
			throw WebError.forbidden
		}
		
		guard let word = try await query(wordID: wordID, on: req.db).first() else {
			throw WebError.notFound
		}
		
		let returnPath = try req.query.get(String?.self, at: "return")
		let dto = try word.toDTOWithIdentifiedRelations()
		
		try await req.db.transaction { db in
			try await word.$translations
				.query(on: db)
				.withDeleted()
				.delete()
			
			try await word.$references
				.query(on: db)
				.withDeleted()
				.delete()
			
			try await word.$backReferences
				.query(on: db)
				.withDeleted()
				.delete()
			
			try await word.delete(force: true, on: db)
		}
		
		return try await renderParmanentlyDeleteItem(success: true, word: dto, return: returnPath, user: user, req: req)
	}
	
	private func renderParmanentlyDeleteItem(success: Bool = false, word: Identified<Word.DTOWithIdentifiedRelations>, return: String?, user: User, req: Request) async throws -> View {
		let context = PermanentlyDeleteItemContext(
			user: try user.toDTO(),
			return: `return` ?? "/",
			word: word,
			success: success,
		)
		
		return try await req.view.render("Pages/permanently-delete-item", context)
	}
}
