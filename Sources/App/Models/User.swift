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
    
    @Field(key: "salt")
    var saltOld: UUID
    
    @Field(key: "password")
    var passwordOld: Data
	
	@Field(key: "password_hash_argon2")
	var passwordHash: String?
    
    init() { }

    init(id: UUID? = nil, name: String, type: UserType, salt: UUID = UUID(), password: String) async throws {
        self.id = id
        self.name = name
        self.type = type
        self.saltOld = salt
        self.passwordOld = Self.hashPasswordOld(password, salt: salt)
		self.passwordHash = try await Self.hashPassword(password)
    }
    
    static func hashPasswordOld(_ password: String, salt: UUID) -> Data {
        var hasher = SHA256()
		hasher.update(data: Data(password.utf8))
		hasher.update(data: Data(salt.uuidString.utf8))
        return Data(hasher.finalize())
    }
	
	func verifyPasswordOld(_ passwordToCheck: String) -> Bool {
		Self.hashPasswordOld(passwordToCheck, salt: self.saltOld).elementsEqual(self.passwordOld)
	}
}

// better password hashing
extension User {
	enum PasswordHashingError: Error {
		case unableToGenerateRandomSalt
		case unreadablePasswordHash
		case unableToVerify
	}
	
	static func hashPassword(_ password: String, salt: Data? = nil) async throws -> String {
		let saltData: Data
		if let salt {
			saltData = salt
		} else {
			let saltLength = 32
			var bytes = [UInt8](repeating: 0, count: saltLength)
			
			guard SecRandomCopyBytes(kSecRandomDefault, saltLength, &bytes) == 0 else {
				throw PasswordHashingError.unableToGenerateRandomSalt
			}
			saltData = Data(bytes)
		}
		
		return try await argon.computeEncoded(password: Data(password.utf8), salt: saltData)
	}
	
	func verifyPassword(_ passwordToCheck: String) async throws -> Bool? {
		guard let passwordHash else {
			return nil
		}
		
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
