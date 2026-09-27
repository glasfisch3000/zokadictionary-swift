import Fluent
import Foundation

final class Word: Model, @unchecked Sendable {
    static let schema = "words"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "string")
    var string: String
    
    @Field(key: "description")
    var description: String?
    
    @Enum(key: "type")
    var type: WordType
    
    @Children(for: \.$source)
    var references: [Reference]
    
    @Children(for: \.$word)
    var translations: [Translation]
	
	@Timestamp(key: "deleted_at", on: .delete)
	var deleted: Date?
    
    init() { }

    init(id: UUID? = nil, string: String, description: String? = nil, type: WordType) {
        self.id = id
        self.string = string
        self.description = description
        self.type = type
    }
}

extension Word {
	enum WordType: String, Sendable, Hashable, Codable {
		case adjective
		case noun
		case number
		case particle
		case preposition
		case questionWord
		case verb
		
		var userString: String {
			switch self {
			case .adjective: "adjective"
			case .noun: "noun"
			case .number: "number"
			case .particle: "particle"
			case .preposition: "preposition"
			case .questionWord: "question word"
			case .verb: "verb"
			}
		}
	}
}

extension Word {
	static func < (lhs: Word, rhs: Word) -> Bool {
		if lhs.string < rhs.string { return true }
		if lhs.string > rhs.string { return false }
		
		if lhs.type.rawValue < rhs.type.rawValue { return true }
		if lhs.type.rawValue > rhs.type.rawValue { return false }
		
		return (lhs.id?.uuidString ?? "") < (rhs.id?.uuidString ?? "")
	}
}
