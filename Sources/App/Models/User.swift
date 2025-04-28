import Fluent
import struct Foundation.Data
import struct Foundation.UUID
import Crypto

final class User: Model, @unchecked Sendable {
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

    init(id: UUID? = nil, name: String, type: UserType, salt: UUID, password: Data) {
        self.id = id
        self.name = name
        self.type = type
        self.salt = salt
        self.password = password
    }
    
    func toDTO() -> UserDTO {
        UserDTO(id: self.id,
                name: self.name,
                type: self.type,
                salt: self.salt,
                password: self.password)
    }
    
    static func hashPassword(_ password: String, salt: UUID) -> Data {
        var hasher = SHA256()
        hasher.update(data: Data(password.utf8))
        hasher.update(data: Data(salt.uuidString.utf8))
        return Data(hasher.finalize())
    }
}
