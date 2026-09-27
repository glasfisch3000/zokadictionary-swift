import Fluent
import struct Foundation.Data
import struct Foundation.UUID
import Crypto

final class User: Model, @unchecked Sendable, ModelSessionAuthenticatable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "username")
    var name: String
    
    @Enum(key: "user_type")
    var type: UserType
    
    @Field(key: "salt")
    var salt: UUID
    
    @Field(key: "password")
    var password: Data
    
    init() { }

    init(id: UUID? = nil, name: String, type: UserType, salt: UUID = UUID(), password: String) {
        self.id = id
        self.name = name
        self.type = type
        self.salt = salt
        self.password = Self.hashPassword(password, salt: salt)
    }
    
	// change to argon2 hashing
    static func hashPassword(_ password: String, salt: UUID) -> Data {
        var hasher = SHA256()
        hasher.update(data: Data(password.utf8))
        hasher.update(data: Data(salt.uuidString.utf8))
        return Data(hasher.finalize())
    }
	
	func verifyPassword(_ passwordToCheck: String) -> Bool {
		Self.hashPassword(passwordToCheck, salt: self.salt).elementsEqual(self.password)
	}
}

extension User {
	enum UserType: String, Sendable, Hashable, Codable {
		case viewer
		case contributor
		case admin
	}
}
