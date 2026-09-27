import Vapor
import Fluent

struct SessionAuthenticator: AsyncRequestAuthenticator {
	func authenticate(request: Request) async throws {
		guard request.hasSession else {
			return
		}
		
		guard let userID = request.session.authenticated(User.self) else {
			return
		}
		
		guard let user = try await User.find(userID, on: request.db) else {
			return
		}
		
		request.auth.login(user)
	}
}
