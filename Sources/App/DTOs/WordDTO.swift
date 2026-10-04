import Fluent
import Vapor
import Foundation

extension Word {
	struct DTO: Hashable, Sendable, Content {
		var string: String
		var description: String?
		var type: Word.WordType
		var deleted: Date?
	}

	struct DTOWithRelations: Hashable, Sendable, Content {
		var string: String
		var description: String?
		var type: Word.WordType
		var deleted: Date?
		
		var references: [Reference.DTO]
		var translations: [Translation.DTO]
	}
	
	struct DTOWithIdentifiedRelations: Hashable, Sendable, Content {
		var string: String
		var description: String?
		var type: Word.WordType
		var deleted: Date?
		
		var references: [Identified<Reference.DTOWithDestination>]
		var backReferences: [Identified<Reference.DTOWithDestination>]
		var translations: [Identified<Translation.DTO>]
	}
	
	func toDTO() throws -> Identified<DTO> {
		.init(
			id: try self.requireID(),
			value: .init(
				string: self.string,
				description: self.description,
				type: self.type,
				deleted: self.deleted,
			)
		)
	}
	
	func toDTOWithIdentifiedRelations() throws -> Identified<DTOWithIdentifiedRelations> {
		.init(
			id: try self.requireID(),
			value: .init(
				string: self.string,
				description: self.description,
				type: self.type,
				deleted: self.deleted,
				references: try self.$references.value?.map { try $0.toDTO() } ?? [],
				backReferences: try self.$backReferences.value?.map { try $0.toDTO() } ?? [],
				translations: try self.$translations.value?.map { try $0.toDTO() } ?? [],
			)
		)
	}
}
