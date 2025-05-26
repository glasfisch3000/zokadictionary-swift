import Fluent
import Foundation

final class Translation: Model, @unchecked Sendable {
    static let schema = "translations"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "translation")
    var translation: String
    
    @Field(key: "comment")
    var comment: String?
    
    @Parent(key: "word_id")
    var word: Word
	
	@Timestamp(key: "deleted_at", on: .delete)
	var deleted: Date?
    
    init() { }
    
    init(id: UUID? = nil, translation: String, comment: String? = nil, wordID: Word.IDValue?) {
        self.id = id
        self.translation = translation
        self.comment = comment
        if let wordID = wordID { self.$word.id = wordID }
    }
    
    init(dto: TranslationDTO) {
        self.id = dto.id
        self.translation = dto.translation
        self.comment = dto.comment
        self.$word.id = dto.wordID
    }
    
    func toDTO() -> TranslationDTO {
        TranslationDTO(id: self.id,
                       wordID: self.$word.id,
                       translation: self.translation,
                       comment: self.comment,
					   deleted: self.deleted)
    }
}
