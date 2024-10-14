import Fluent
import struct Foundation.UUID

final class Word: Model, Sendable {
    static let schema = "words"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "string")
    var string: String
    
    @Field(key: "description")
    var description: String?
    
    @Enum(key: "type")
    var type: WordType
    
    @Siblings(through: Reference.self, from: \.$source, to: \.$destination)
    var references: [Word]
    
    @Children(for: \.$word)
    var translations: [Translation]
    
    init() { }

    init(id: UUID? = nil, string: String, description: String? = nil, type: WordType) {
        self.id = id
        self.string = string
        self.description = description
        self.type = type
    }
    
    func toDTO() -> WordDTO {
        WordDTO(id: self.id,
                string: self.string,
                description: self.description,
                type: self.type,
                references: self.$references.pivots.map { $0.toDTO() },
                translations: self.translations.map { $0.toDTO() })
    }
}
