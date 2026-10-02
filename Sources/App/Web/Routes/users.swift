import Vapor
import Fluent

extension WebRoutes {
	func getManageUsers(req: Request) async throws -> View {
		struct Context: Encodable {
			var user: Identified<User.DTO>
			var `return`: String
			var users: [Identified<User.DTO>]
		}
		
		let user = try req.auth.require(User.self)
		guard user.type == .admin else {
			throw WebError.forbidden
		}
		
		let returnPath = try req.query.get(String?.self, at: "return")
		
		let users = try await User
			.query(on: req.db)
			.all()
		
		let context = Context(
			user: try user.toDTO(),
			return: returnPath ?? "/",
			users: try users.map { try $0.toDTO() },
		)
		
		return try await req.view.render("Pages/manage-users", context)
	}
}

extension WebRoutes {
	private struct DeleteUserContext: Encodable {
		enum Error: String, Encodable {
			case passwordIncorrect
			case cannotDeleteSelf
		}
		
		var user: Identified<User.DTO>
		var `return`: String
		var targetUser: Identified<User.DTO>
		var success: Bool
		var error: Self.Error?
	}
	
	func getDeleteUser(req: Request) async throws -> View {
		guard let userID = req.parameters.get("userID", as: UUID.self) else {
			throw WebError.malformedRequest
		}
		
		let user = try req.auth.require(User.self)
		guard user.type == .admin else {
			throw WebError.forbidden
		}
		
		guard let targetUser = try await User.find(userID, on: req.db) else {
			throw WebError.notFound
		}
		
		let returnPath = try req.query.get(String?.self, at: "return")
		
		return try await renderDeleteUser(targetUser: targetUser, return: returnPath, user: user, req: req)
	}
	
	func postDeleteUser(req: Request) async throws -> View {
		struct Data: Decodable {
			var password: String
		}
		
		guard let userID = req.parameters.get("userID", as: UUID.self) else {
			throw WebError.malformedRequest
		}
		
		let user = try req.auth.require(User.self)
		guard user.type == .admin else {
			throw WebError.forbidden
		}
		
		guard let targetUser = try await User.find(userID, on: req.db) else {
			throw WebError.notFound
		}
		
		let returnPath = try req.query.get(String?.self, at: "return")
		let data = try req.content.decode(Data.self)
		
		guard user.verifyPassword(data.password) ?? user.verifyPasswordOld(data.password) else {
			return try await renderDeleteUser(error: .passwordIncorrect, targetUser: targetUser, return: returnPath, user: user, req: req)
		}
		if try user.requireID() == userID {
			return try await renderDeleteUser(error: .cannotDeleteSelf, targetUser: targetUser, return: returnPath, user: user, req: req)
		}
		
		try await targetUser.delete(on: req.db)
		
		return try await renderDeleteUser(success: true, targetUser: targetUser, return: returnPath, user: user, req: req)
	}
	
	private func renderDeleteUser(success: Bool = false, error: DeleteUserContext.Error? = nil, targetUser: User, return: String?, user: User, req: Request) async throws -> View {
		let context = DeleteUserContext(
			user: try user.toDTO(),
			return: `return` ?? "/",
			targetUser: try targetUser.toDTO(),
			success: success,
			error: error,
		)
		
		return try await req.view.render("Pages/delete-user", context)
	}
}

extension WebRoutes {
	private struct NewUserContext: Encodable {
		enum Error: String, Encodable {
			case invalidNewUsername
			case invalidNewPassword
			case nameAlreadyTaken
			case passwordIncorrect
			case passwordsDoNotMatch
		}
		
		var user: Identified<User.DTO>
		var `return`: String
		var success: Bool
		var error: Self.Error?
	}
	
	func getNewUser(req: Request) async throws -> View {
		let user = try req.auth.require(User.self)
		guard user.type == .admin else {
			throw WebError.forbidden
		}
		
		let returnPath = try req.query.get(String?.self, at: "return")
		
		return try await renderNewUser(return: returnPath, user: user, req: req)
	}
	
	func postNewUser(req: Request) async throws -> View {
		struct DTO: Codable {
			enum CodingKeys: String, CodingKey {
				case username
				case type
				case newPassword = "new-password"
				case repeatNewPassword = "repeat-new-password"
				case currentPassword = "current-password"
			}
			
			var username: String
			var type: User.UserType
			var newPassword: String
			var repeatNewPassword: String
			var currentPassword: String
		}
		
		let user = try req.auth.require(User.self)
		guard user.type == .admin else {
			throw WebError.forbidden
		}
		
		let returnPath = try req.query.get(String?.self, at: "return")
		let dto = try req.content.decode(DTO.self)
		
		if dto.username.isEmpty {
			return try await renderNewUser(error: .invalidNewUsername, return: returnPath, user: user, req: req)
		}
		
		if dto.newPassword.isEmpty {
			return try await renderNewUser(error: .invalidNewPassword, return: returnPath, user: user, req: req)
		}
		
		guard dto.newPassword == dto.repeatNewPassword else {
			return try await renderNewUser(error: .passwordsDoNotMatch, return: returnPath, user: user, req: req)
		}
		
		guard user.verifyPassword(dto.currentPassword) ?? user.verifyPasswordOld(dto.currentPassword) else {
			return try await renderNewUser(error: .passwordIncorrect, return: returnPath, user: user, req: req)
		}
		
		guard try await User
			.query(on: req.db)
			.filter(\.$name == dto.username)
			.first() == nil else {
			return try await renderNewUser(error: .nameAlreadyTaken, return: returnPath, user: user, req: req)
		}
		
		let newUser = User(name: dto.username, type: dto.type, password: dto.newPassword)
		try await newUser.create(on: req.db)
		
		return try await renderNewUser(success: true, return: returnPath, user: user, req: req)
	}
	
	private func renderNewUser(success: Bool = false, error: NewUserContext.Error? = nil, return: String?, user: User, req: Request) async throws -> View {
		let context = NewUserContext(
			user: try user.toDTO(),
			return: `return` ?? "/",
			success: success,
			error: error,
		)
		
		return try await req.view.render("Pages/new-user", context)
	}
}
