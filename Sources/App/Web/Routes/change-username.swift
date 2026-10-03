import Vapor
import Fluent

extension WebRoutes {
	private struct ChangeUsernameContext: Encodable {
		enum Error: String, Encodable {
			case invalidName
			case nameAlreadyTaken
			case passwordIncorrect
		}
		
		var user: Identified<User.DTO>
		var success: Bool
		var error: Self.Error?
		var `return`: String
	}
	
	func getChangeUsername(req: Request) async throws -> View {
		let user = try req.auth.require(User.self)
		let returnPath = try req.query.get(String?.self, at: "return")
		
		return try await renderChangeUsername(return: returnPath, user: user, req: req)
	}
	
	func postChangeUsername(req: Request) async throws -> View {
		struct Data: Codable {
			enum CodingKeys: String, CodingKey {
				case newUsername = "new-username"
				case password
			}
			
			var newUsername: String
			var password: String
		}
		
		let user = try req.auth.require(User.self)
		let returnPath = try req.query.get(String?.self, at: "return")
		let data = try req.content.decode(Data.self)
		
		guard user.verifyPassword(data.password) ?? user.verifyPasswordOld(data.password) else {
			return try await renderChangeUsername(error: .passwordIncorrect, return: returnPath, user: user, req: req)
		}
		
		if data.newUsername.isEmpty {
			return try await renderChangeUsername(error: .invalidName, return: returnPath, user: user, req: req)
		}
		
		guard try await User.query(on: req.db).filter(\.$name == data.newUsername).first() == nil else {
			return try await renderChangeUsername(error: .nameAlreadyTaken, return: returnPath, user: user, req: req)
		}
		
		user.name = data.newUsername
		try await user.update(on: req.db)
		
		return try await renderChangeUsername(success: true, return: returnPath, user: user, req: req)
	}
	
	private func renderChangeUsername(success: Bool = false, error: ChangeUsernameContext.Error? = nil, return: String?, user: User, req: Request) async throws -> View {
		let context = ChangeUsernameContext(
			user: try user.toDTO(),
			success: success,
			error: error,
			return: `return` ?? "/",
		)
		
		return try await req.view.render("Pages/change-username", context)
	}
}
