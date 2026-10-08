import Vapor
import Fluent

extension WebRoutes {
	private struct DeleteItemContext: Encodable {
		var user: Identified<User.DTO>
		var `return`: String
		var word: Identified<Word.DTOWithIdentifiedRelations>
		var success: Bool
	}
	
	private func query(wordID: Word.IDValue, on db: any Database) -> QueryBuilder<Word> {
		Word.query(on: db)
			.filter(\.$id == wordID)
			.with(\.$translations)
			.with(\.$references, {
				$0.with(\.$destination, withDeleted: true)
			})
	}
	
	func getDeleteItem(req: Request) async throws -> View {
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
		
		return try await renderDeleteItem(word: dto, return: returnPath, user: user, req: req)
	}
	
	func postDeleteItem(req: Request) async throws -> View {
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
		
		try await word.delete(on: req.db)
		return try await renderDeleteItem(success: true, word: dto, return: returnPath, user: user, req: req)
	}
	
	private func renderDeleteItem(success: Bool = false, word: Identified<Word.DTOWithIdentifiedRelations>, return: String?, user: User, req: Request) async throws -> View {
		let context = DeleteItemContext(
			user: try user.toDTO(),
			return: `return` ?? "/",
			word: word,
			success: success,
		)
		
		return try await req.view.render("Pages/delete-item", context)
	}
}
