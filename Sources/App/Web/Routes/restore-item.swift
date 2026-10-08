import Vapor
import Fluent

extension WebRoutes {
	private struct RestoreItemContext: Encodable {
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
	
	func getRestoreItem(req: Request) async throws -> View {
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
		
		return try await renderRestoreItem(word: word, return: returnPath, user: user, req: req)
	}
	
	func postRestoreItem(req: Request) async throws -> View {
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
		
		try await word.restore(on: req.db)
		return try await renderRestoreItem(success: true, word: word, return: returnPath, user: user, req: req)
	}
	
	private func renderRestoreItem(success: Bool = false, word: Word, return: String?, user: User, req: Request) async throws -> View {
		let context = RestoreItemContext(
			user: try user.toDTO(),
			return: `return` ?? "/",
			word: try word.toDTOWithIdentifiedRelations(withDeletedReferences: true),
			success: success,
		)
		
		return try await req.view.render("Pages/restore-item", context)
	}
}
