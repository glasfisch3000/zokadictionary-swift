import Vapor
import Fluent

extension WebRoutes {
	private struct ChangePasswordContext: Encodable {
		enum Error: String, Encodable {
			case invalidNewPassword
			case passwordsDoNotMatch
			case passwordIncorrect
		}
		
		var user: Identified<User.DTO>
		var success: Bool
		var error: Self.Error?
		var `return`: String
	}
	
	func getChangePassword(req: Request) async throws -> View {
		let user = try req.auth.require(User.self)
		let returnPath = try req.query.get(String?.self, at: "return")
		
		return try await renderChangePassword(return: returnPath, user: user, req: req)
	}
	
	func postChangePassword(req: Request) async throws -> View {
		struct DTO: Codable {
			enum CodingKeys: String, CodingKey {
				case newPassword = "new-password"
				case repeatNewPassword = "repeat-new-password"
				case password = "current-password"
			}
			
			var newPassword: String
			var repeatNewPassword: String
			var password: String
		}
		
		let user = try req.auth.require(User.self)
		let returnPath = try req.query.get(String?.self, at: "return")
		let data = try req.content.decode(DTO.self)
		
		guard try await user.verifyPassword(data.password) else {
			return try await renderChangePassword(error: .passwordIncorrect, return: returnPath, user: user, req: req)
		}
		
		if data.newPassword.isEmpty {
			return try await renderChangePassword(error: .invalidNewPassword, return: returnPath, user: user, req: req)
		}
		
		guard data.newPassword.elementsEqual(data.repeatNewPassword) else {
			return try await renderChangePassword(error: .passwordsDoNotMatch, return: returnPath, user: user, req: req)
		}
		
		user.passwordHash = try await User.hashPassword(data.newPassword)
		try await user.update(on: req.db)
		
		return try await renderChangePassword(success: true, return: returnPath, user: user, req: req)
	}
	
	private func renderChangePassword(success: Bool = false, error: ChangePasswordContext.Error? = nil, return: String?, user: User, req: Request) async throws -> View {
		let context = ChangePasswordContext(
			user: try user.toDTO(),
			success: success,
			error: error,
			return: `return` ?? "/",
		)
		
		return try await req.view.render("Pages/change-password", context)
	}
}
