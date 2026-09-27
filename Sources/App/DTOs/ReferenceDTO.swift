import Vapor
import Foundation

extension Reference {
	struct DTO: Hashable, Sendable, Content {
		var destinationID: Word.IDValue
		var comment: String?
	}
	
	func toDTO() throws -> Identified<DTO> {
		.init(
			id: try self.requireID(),
			value: .init(
				destinationID: self.$destination.id,
				comment: self.comment,
			)
		)
	}
}
