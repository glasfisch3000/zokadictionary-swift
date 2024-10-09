import Fluent
import Vapor

struct TranslationDTO: Hashable, Sendable, Content {
    var id: UUID?
    var wordID: Word.IDValue?
    var translation: String
    var comment: String?

    func toModel() -> Translation {
        Translation(id: self.id,
                    translation: self.translation,
                    comment: self.comment,
                    wordID: self.wordID)
    }
}
