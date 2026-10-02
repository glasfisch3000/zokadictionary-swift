import Fluent
import Foundation

final class Reference: Model, @unchecked Sendable {
    static let schema = "references"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "source_id")
    var source: Word
    
    @Parent(key: "destination_id")
    var destination: Word
    
    @Field(key: "comment")
    var comment: String?
	
	@Timestamp(key: "deleted_at", on: .delete)
	var deleted: Date?
    
    init() { }
    
    init(id: UUID? = nil, sourceID: Word.IDValue, destinationID: Word.IDValue, comment: String? = nil) {
        self.id = id
        self.$source.id = sourceID
        self.$destination.id = destinationID
        self.comment = comment
    }
}
