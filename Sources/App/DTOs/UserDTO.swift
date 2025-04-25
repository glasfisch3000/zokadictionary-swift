import Fluent
import Vapor

struct UserDTO: Hashable, Sendable, Content {
    var id: UUID?
    var name: String
    var type: UserType
    var salt: UUID
    var password: Data
}
