import Fluent
import Vapor
import Foundation

struct WordDTO: Hashable, Sendable, Content {
    var id: UUID?
    var string: String
    var description: String?
    var type: WordType
	var deleted: Date?
    
    var references: [ReferenceDTO]?
    var translations: [TranslationDTO]?
}
