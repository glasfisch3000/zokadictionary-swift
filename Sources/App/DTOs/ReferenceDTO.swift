import Vapor
import Foundation

extension Reference {
	struct DTO: Hashable, Sendable, Content {
		var destinationID: Word.IDValue
		var comment: String?
	}
	
	struct DTOWithDestination: Hashable, Sendable, Content {
		var destination: Identified<Word.DTO>
		var comment: String?
	}
	
	// careful, this might panic if the destination hasn't been fetched!
	func toDTO() throws -> Identified<DTOWithDestination> {
		.init(
			id: try self.requireID(),
			value: .init(
				destination: try self.destination.toDTO(),
				comment: self.comment,
			)
		)
	}
}

extension Reference.DTO {
	mutating func validate() -> Bool {
		Reference.validate(comment: &self.comment)
	}
}
