import Fluent
import struct Foundation.UUID

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
    
    init() { }
    
    init(id: UUID? = nil, sourceID: Word.IDValue?, destinationID: Word.IDValue, comment: String? = nil) {
        self.id = id
        if let sourceID = sourceID { self.$source.id = sourceID }
        self.$destination.id = destinationID
        self.comment = comment
    }
    
    init(dto: ReferenceDTO) {
        self.id = dto.id
        self.comment = dto.comment
        self.$source.id = dto.sourceID
        self.$destination.id = dto.destinationID
    }
    
    func toDTO() -> ReferenceDTO {
        ReferenceDTO(id: self.id,
                     sourceID: self.$source.id,
                     destinationID: self.$destination.id,
                     comment: self.comment)
    }
}
