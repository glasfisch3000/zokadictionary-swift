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
    
    init() { }
    
    init(id: UUID? = nil, sourceID: Word.IDValue, destinationID: Word.IDValue, comment: String? = nil) {
        self.id = id
        self.$source.id = sourceID
        self.$destination.id = destinationID
        self.comment = comment
    }
}

extension Reference {
	private static let validCharacters = CharacterSet.alphanumerics.union(.punctuationCharacters).union([" "])
	
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
