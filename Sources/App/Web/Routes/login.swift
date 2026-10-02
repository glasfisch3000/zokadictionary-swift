import Vapor
import Fluent

extension WebRoutes {
	private struct LoginPageContext: Codable {
		var success: Bool
		var error: AuthError?
		var `return`: String
	}
	
	func getLogin(req: Request) async throws -> View {
		struct Query: Codable {
			var error: AuthError?
			var `return`: String?
		}
		
		let query = try req.query.decode(Query.self)
		return try await renderLogin(error: query.error, return: query.return, req: req)
	}
	
	func postLogin(req: Request) async throws -> View {
		struct Credentials: Codable {
			var username: String
			var password: String
		}
		
		let credentials = try req.content.decode(Credentials.self)
		let returnPath = try req.query.get(String?.self, at: "return")
		
		guard let user = try await User
			.query(on: req.db)
			.filter(\.$name == credentials.username)
			.first() else {
			return try await renderLogin(error: .invalidLoginData, return: returnPath, req: req)
		}
		
		switch try user.verifyPassword(credentials.password) {
		case true: break
		case false: return try await renderLogin(error: .invalidLoginData, return: returnPath, req: req)
		case nil:
			guard user.verifyPasswordOld(credentials.password) else {
				return try await renderLogin(error: .invalidLoginData, return: returnPath, req: req)
			}
			
			user.passwordHash = try User.hashPassword(credentials.password)
		}
		
		req.session.authenticate(user)
		
		return try await renderLogin(success: true, return: returnPath, req: req)
	}
	
	private func renderLogin(success: Bool = false, error: AuthError? = nil, return: String?, req: Request) async throws -> View {
		return try await req.view.render(
			"Pages/login",
			LoginPageContext(
				success: success,
				error: error,
				return: `return` ?? "/"
			)
		)
	}
}
