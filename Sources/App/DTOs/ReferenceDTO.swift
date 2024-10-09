import Fluent
import Vapor

struct ReferenceDTO: Hashable, Sendable, Content {
    var id: UUID?
    var sourceID: Word.IDValue?
    var destinationID: Word.IDValue
    var comment: String?

    func toModel() -> Reference {
        Reference(id: self.id,
                  sourceID: self.sourceID,
                  destinationID: self.destinationID,
                  comment: self.comment)
    }
}
