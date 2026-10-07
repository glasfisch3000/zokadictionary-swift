import Fluent
import struct Foundation.Data
import struct Foundation.UUID
import Crypto
import SwiftArgon2
import Vapor

private let argon = try! Argon2(params: .init(variant: .argon2id))

final class User: Model, @unchecked Sendable, ModelSessionAuthenticatable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "username")
    var name: String
    
    @Enum(key: "user_type")
    var type: UserType
	
	@Field(key: "password_hash_argon2")
	var passwordHash: String
    
    init() { }

    init(id: UUID? = nil, name: String, type: UserType, password: String) async throws {
        self.id = id
        self.name = name
        self.type = type
		self.passwordHash = try await Self.hashPassword(password)
    }
}

extension User {
	enum PasswordHashingError: Error {
		case unableToGenerateRandomSalt
		case unreadablePasswordHash
		case unableToVerify
	}
	
	static func hashPassword(_ password: String, salt: Data? = nil) async throws -> String {
		let saltData = if let salt {
			salt
		} else {
			Data([UInt8].random(count: 32))
		}
		
		return try await argon.computeEncoded(password: Data(password.utf8), salt: saltData)
	}
	
	func verifyPassword(_ passwordToCheck: String) async throws -> Bool {
		switch try await Argon2.verify(password: Data(passwordToCheck.utf8), encoded: passwordHash) {
		case .some(let result): return result
		case nil: throw PasswordHashingError.unableToVerify
		}
	}
}

extension User {
	enum UserType: String, Sendable, Hashable, Codable {
		case viewer
		case contributor
		case admin
	}
}

extension User {
	static func checkIsValid(username: String) -> Bool {
		let validCharacters = CharacterSet.alphanumerics.union([".", "_", "-"])
		
		if username.isEmpty { return false }
		guard username.rangeOfCharacter(from: validCharacters.inverted) == nil else { return false }
		if username.count > 32 { return false }
		return true
	}
	
	static func checkIsValid(password: String) -> Bool {
		if password.isEmpty { return false }
		return true
	}
}
