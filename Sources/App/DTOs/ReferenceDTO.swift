import Fluent
import Vapor

struct ReferenceDTO: Hashable, Sendable, Content {
    var id: UUID?
    var sourceID: Word.IDValue
    var destinationID: Word.IDValue
    var comment: String?
    
    struct Explicit: Hashable, Sendable, Content {
        var id: UUID
        var sourceID: Word.IDValue
        var destinationID: Word.IDValue
        var comment: String?
    }
}
