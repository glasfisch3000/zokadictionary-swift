import Fluent
import Vapor
import Foundation

extension Translation {
	struct DTO: Hashable, Sendable, Content {
		var translation: String
		var comment: String?
	}
	
	func toDTO() throws -> Identified<DTO> {
		.init(
			id: try self.requireID(),
			value: .init(
				translation: self.translation,
				comment: self.comment,
			)
		)
	}
}

extension Translation.DTO {
	mutating func validate() -> Bool {
		Translation.validate(translation: &self.translation) &&
		Translation.validate(comment: &self.comment)
	}
}
