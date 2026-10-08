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
	
	struct DTOWithSource: Hashable, Sendable, Content {
		var source: Identified<Word.DTO>
		var comment: String?
	}
	
	// careful, this might panic if the destination hasn't been fetched!
	func toDTOWithDestination(withDeleted: Bool = false) throws -> Identified<DTOWithDestination>? {
		guard withDeleted || self.destination.deleted == nil else {
			return nil
		}
		
		return .init(
			id: try self.requireID(),
			value: .init(
				destination: try self.destination.toDTO(),
				comment: self.comment,
			)
		)
	}
	
	// careful, this might panic if the source hasn't been fetched!
	func toDTOWithSource(withDeleted: Bool) throws -> Identified<DTOWithSource>? {
		guard withDeleted || self.source.deleted == nil else {
			return nil
		}
		
		return .init(
			id: try self.requireID(),
			value: .init(
				source: try self.source.toDTO(),
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
