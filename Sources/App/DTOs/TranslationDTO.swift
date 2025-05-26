import Fluent
import Vapor
import Foundation

struct TranslationDTO: Hashable, Sendable, Content {
    var id: UUID?
    var wordID: Word.IDValue
    var translation: String
    var comment: String?
	var deleted: Date?
    
    struct Explicit: Hashable, Sendable, Content {
        var id: UUID
        var wordID: Word.IDValue
        var translation: String
        var comment: String?
    }
}
