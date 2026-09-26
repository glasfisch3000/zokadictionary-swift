import Fluent
import Vapor

struct UserDTO: Hashable, Sendable, Content {
    var id: UUID?
    var name: String
	var type: User.UserType
    var salt: UUID
    var password: Data
}
