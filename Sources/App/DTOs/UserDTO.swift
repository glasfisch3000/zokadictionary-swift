import Fluent
import Vapor

extension User {
	struct DTO: Hashable, Sendable, Content {
		var name: String
		var type: User.UserType
	}
	
	func toDTO() throws -> Identified<DTO> {
		.init(
			id: try self.requireID(),
			value: .init(
				name: self.name,
				type: self.type,
			)
		)
	}
}
