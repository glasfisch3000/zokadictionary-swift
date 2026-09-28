import Vapor
import Foundation

extension Reference {
	struct DTO: Hashable, Sendable, Content {
		var destination: Identified<Word.DTO>
		var comment: String?
	}
	
	// careful, this might panic if the destination hasn't been fetched!
	func toDTO() throws -> Identified<DTO> {
		.init(
			id: try self.requireID(),
			value: .init(
				destination: try self.destination.toDTO(),
				comment: self.comment,
			)
		)
	}
}
