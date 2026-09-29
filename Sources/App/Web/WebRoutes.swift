import Vapor

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
		
		routes.get(use: index(req:))
		routes.get("words", use: getSearch(req:))
		
		routes.group("new-item") {
			$0.get(use: getNewItem(req:))
			$0.post(use: postNewItem(req:))
		}
		
		routes.group("change-username") {
			$0.get(use: getChangeUsername(req:))
			$0.post(use: postChangeUsername(req:))
		}
		
//		try routes
//			.grouped(User.guardMiddleware(throwing: AuthError.missingLogin))
//			.register(collection: AuthenticatedRoutes(storage: storage))
	}
}
