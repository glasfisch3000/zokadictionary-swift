import Fluent
import struct Foundation.Data
import struct Foundation.UUID
import Crypto
import Sodium
import Vapor

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

    init(id: UUID? = nil, name: String, type: UserType, salt: UUID = UUID(), password: String) {
        self.id = id
        self.name = name
        self.type = type
        self.saltOld = salt
        self.passwordOld = Self.hashPasswordOld(password, salt: salt)
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
	struct PasswordHashingError: Error { }
	
	static func hashPassword(_ password: String) throws(PasswordHashingError) -> String {
		let sodium = Sodium().pwHash
		if let hash = sodium.str(passwd: password.bytes, opsLimit: sodium.OpsLimitInteractive, memLimit: sodium.MemLimitInteractive) {
			return hash
		} else {
			throw PasswordHashingError()
		}
	}
	
	func verifyPassword(_ passwordToCheck: String) -> Bool? {
		let sodium = Sodium().pwHash
		return self.passwordHash.map { sodium.strVerify(hash: $0, passwd: passwordToCheck.bytes) }
	}
}

extension User {
	enum UserType: String, Sendable, Hashable, Codable {
		case viewer
		case contributor
		case admin
	}
}
