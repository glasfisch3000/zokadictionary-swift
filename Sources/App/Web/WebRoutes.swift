import Vapor
import Fluent

struct WebRoutes: RouteCollection {
	func boot(routes: any RoutesBuilder) throws {
		routes.group("login") {
			$0.get(use: getLogin(req:))
			$0.post(use: postLogin(req:))
		}
		
		routes.group("logout") {
			$0.get(use: getLogout(req:))
			$0.post(use: postLogout(req:))
		}
		
//		try routes
//			.grouped(User.guardMiddleware(throwing: AuthError.missingLogin))
//			.register(collection: AuthenticatedRoutes(storage: storage))
	}
}

extension WebRoutes {
	struct LoginPageContext: Codable {
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
		let returnAddress = try req.query.get(String?.self, at: "return")
		
		guard let user = try await User
			.query(on: req.db)
			.filter(\.$name == credentials.username)
			.first() else {
			return try await renderLogin(error: .invalidLoginData, return: returnAddress, req: req)
		}
		
		guard user.verifyPassword(credentials.password) else {
			return try await renderLogin(error: .invalidLoginData, return: returnAddress, req: req)
		}
		
		req.session.authenticate(user)
		
		return try await renderLogin(success: true, return: returnAddress, req: req)
	}
	
	func renderLogin(success: Bool = false, error: AuthError? = nil, return: String?, req: Request) async throws -> View {
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

extension WebRoutes {
	func getLogout(req: Request) async throws -> View {
		try await req.view.render("Pages/logout")
	}
	
	func postLogout(req: Request) async throws -> View {
		req.session.destroy()
		req.auth.logout(User.self)
		return try await req.view.render("Pages/logout", ["success": true])
	}
}
