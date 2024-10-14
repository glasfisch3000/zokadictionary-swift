import Fluent
import Vapor

struct WordDTO: Hashable, Sendable, Content {
    var id: UUID?
    var string: String
    var description: String?
    var type: WordType
    
    var references: [ReferenceDTO]
    var translations: [TranslationDTO]

    func toModel() -> Word {
        Word(id: self.id,
             string: self.string,
             description: self.description,
             type: self.type)
    }
}
