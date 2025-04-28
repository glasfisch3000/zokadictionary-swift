import Fluent
import struct Foundation.UUID

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
    
    init() { }

    init(id: UUID? = nil, string: String, description: String? = nil, type: WordType) {
        self.id = id
        self.string = string
        self.description = description
        self.type = type
    }
    
    init(dto: WordDTO) {
        self.id = dto.id
        self.string = dto.string
        self.description = dto.description
        self.type = dto.type
    }
    
    func toDTO() -> WordDTO {
        WordDTO(id: self.id,
                string: self.string,
                description: self.description,
                type: self.type,
                references: self.references.map { $0.toDTO() },
                translations: self.translations.map { $0.toDTO() })
    }
}
