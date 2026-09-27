import Vapor

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
