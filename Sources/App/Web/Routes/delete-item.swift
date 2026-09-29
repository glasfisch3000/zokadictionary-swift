import Vapor
import Fluent

extension WebRoutes {
	private struct DeleteItemContext: Encodable {
		var user: Identified<User.DTO>
		var `return`: String
		var word: Identified<Word.DTOWithIdentifiedRelations>
		var success: Bool
	}
	
	func getDeleteItem(req: Request) async throws -> View {
		guard let wordID = req.parameters.get("wordID", as: UUID.self) else {
			throw WebError.malformedRequest
		}
		
		let user = try req.auth.require(User.self)
		guard user.type == .admin || user.type == .contributor else {
			throw WebError.forbidden
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
		
		let returnPath = try req.query.get(String?.self, at: "return")
		
		return try await renderDeleteItem(word: word, return: returnPath, user: user, req: req)
	}
	
	func postDeleteItem(req: Request) async throws -> View {
		guard let wordID = req.parameters.get("wordID", as: UUID.self) else {
			throw WebError.malformedRequest
		}
		
		let user = try req.auth.require(User.self)
		guard user.type == .admin || user.type == .contributor else {
			throw WebError.forbidden
		}
		
		guard let word = try await Word.find(wordID, on: req.db) else {
			throw WebError.notFound
		}
		
		let returnPath = try req.query.get(String?.self, at: "return")
		
		try await req.db.transaction { db in
			try await word.$translations
				.query(on: db)
				.delete()
			
			try await word.$references
				.query(on: db)
				.delete()
			
			try await Reference
				.query(on: db)
				.filter(\.$destination.$id == wordID)
				.delete()
			
			try await word.delete(on: db)
		}
		
		return try await renderDeleteItem(success: true, word: word, return: returnPath, user: user, req: req)
	}
	
	private func renderDeleteItem(success: Bool = false, word: Word, return: String?, user: User, req: Request) async throws -> View {
		let context = DeleteItemContext(
			user: try user.toDTO(),
			return: `return` ?? "/",
			word: try word.toDTOWithIdentifiedRelations(),
			success: success,
		)
		
		return try await req.view.render("Pages/delete-item", context)
	}
}
