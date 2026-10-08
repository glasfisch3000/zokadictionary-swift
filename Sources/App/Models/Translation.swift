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
    
    init() { }
    
    init(id: UUID? = nil, translation: String, comment: String? = nil, wordID: Word.IDValue?) {
        self.id = id
        self.translation = translation
        self.comment = comment
        if let wordID = wordID { self.$word.id = wordID }
    }
}

extension Translation {
	private static let validCharacters = CharacterSet.alphanumerics.union(.punctuationCharacters).union([" "])
	
	static func validate(translation: inout String) -> Bool {
		translation = translation.trimmingCharacters(in: .whitespacesAndNewlines)
		
		if translation.isEmpty { return false }
		guard translation.rangeOfCharacter(from: validCharacters.inverted) == nil else { return false }
		if translation.count > 64 { return false }
		return true
	}
	
	static func validate(comment: inout String?) -> Bool {
		guard let c = comment?.trimmingCharacters(in: .whitespacesAndNewlines) else { return true }
		
		if c.isEmpty {
			comment = nil
			return true
		}
		guard c.rangeOfCharacter(from: validCharacters.inverted) == nil else { return false }
		if c.count > 128 { return false }
		
		comment = c
		return true
	}
}
