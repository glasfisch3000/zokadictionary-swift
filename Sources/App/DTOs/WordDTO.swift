import Fluent
import Vapor

struct WordDTO: Hashable, Sendable, Content {
    var id: UUID?
    var string: String
    var description: String?
    var type: WordType
    
    var references: [ReferenceDTO]
    var translations: [TranslationDTO]
}
