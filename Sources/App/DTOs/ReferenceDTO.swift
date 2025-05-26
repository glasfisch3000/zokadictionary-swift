import Fluent
import Vapor
import Foundation

struct ReferenceDTO: Hashable, Sendable, Content {
    var id: UUID?
    var sourceID: Word.IDValue
    var destinationID: Word.IDValue
    var comment: String?
	var deleted: Date?
    
    struct Explicit: Hashable, Sendable, Content {
        var id: UUID
        var sourceID: Word.IDValue
        var destinationID: Word.IDValue
        var comment: String?
    }
}
