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
		var backReferences: [Identified<Reference.DTOWithSource>]
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
	
	func toDTOWithIdentifiedRelations(withDeletedReferences: Bool = false) throws -> Identified<DTOWithIdentifiedRelations> {
		.init(
			id: try self.requireID(),
			value: .init(
				string: self.string,
				description: self.description,
				type: self.type,
				deleted: self.deleted,
				references: try self.$references.value?.compactMap { try $0.toDTOWithDestination(withDeleted: withDeletedReferences) } ?? [],
				backReferences: try self.$backReferences.value?.compactMap { try $0.toDTOWithSource(withDeleted: withDeletedReferences) } ?? [],
				translations: try self.$translations.value?.map { try $0.toDTO() } ?? [],
			)
		)
	}
}
