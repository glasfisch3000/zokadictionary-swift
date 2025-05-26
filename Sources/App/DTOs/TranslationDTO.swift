import Fluent
import Vapor
import Foundation

struct TranslationDTO: Hashable, Sendable, Content {
    var id: UUID?
    var wordID: Word.IDValue
    var translation: String
    var comment: String?
    
    struct Explicit: Hashable, Sendable, Content {
        var id: UUID
        var wordID: Word.IDValue
        var translation: String
        var comment: String?
    }
}
