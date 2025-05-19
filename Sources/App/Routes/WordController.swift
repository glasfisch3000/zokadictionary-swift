import Fluent
import Vapor
import PostgresNIO

struct WordController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: self.getAll(req:))
        routes.grouped(AuthMiddleware(requiresMaintainer: true)).post(use: self.create(req:))
        
        routes.group(":wordID") { word in
            word.get(use: self.get(req:))
            
            let authWord = word.grouped(AuthMiddleware(requiresMaintainer: true))
            authWord.patch(use: self.update(req:))
            authWord.delete(use: self.delete(req:))
        }
    }

    @Sendable
    func getAll(req: Request) async throws -> [WordDTO] {
        try await Word.query(on: req.db)
            .with(\.$references)
            .with(\.$translations)
            .all()
            .map { $0.toDTO() }
    }
    
    @Sendable
    func get(req: Request) async throws -> WordDTO {
        guard let id = req.parameters.get("wordID", as: UUID.self) else {
            throw RequestError.missingQueryProperty("word id")
        }
        
        guard let word = try await Word.find(id, on: req.db) else {
            throw RequestError.requestedModelNotFound(id, type: "word")
        }
        
        return word.toDTO()
    }

    @Sendable
    func create(req: Request) async throws -> WordDTO {
        var body = try await req.body.collect(upTo: 1_000_000)
        guard let wordDTO = try? body.readJSONDecodable(WordDTO.self, length: body.readableBytes) else {
            throw RequestError.unableToDecodeBody(type: "word")
        }
        
        let word = Word(dto: wordDTO)
        try await word.save(on: req.db)
        
        try await word.$references.create(wordDTO.references.map(Reference.init(dto:)), on: req.db)
        try await word.$translations.create(wordDTO.translations.map(Translation.init(dto:)), on: req.db)
        
        return word.toDTO()
    }
    
    @Sendable
    func update(req: Request) async throws -> WordDTO {
        guard let id = req.parameters.get("wordID", as: UUID.self) else {
            throw RequestError.missingQueryProperty("word id")
        }
        
        guard let word = try await Word.find(id, on: req.db) else {
            throw RequestError.requestedModelNotFound(id, type: "word")
        }
        
        struct Container: Decodable {
            var string: String
            var description: String?
            var type: WordType
            
            var removedTranslations: [Translation.IDValue]
            var editedTranslations: [TranslationDTO.Explicit]
            var addedTranslations: [TranslationDTO]
            
            var removedReferences: [Translation.IDValue]
            var editedReferences: [ReferenceDTO.Explicit]
            var addedReferences: [ReferenceDTO]
        }
        
        var body = try await req.body.collect(upTo: 1_000_000)
        guard let container = try? body.readJSONDecodable(Container.self, length: body.readableBytes) else {
            throw RequestError.unableToDecodeBody(type: "word")
        }
        
        return try await req.db.transaction { database in
			word.string = container.string
			word.description = container.description
			word.type = container.type
			try await word.update(on: database)
            
            try await Translation.query(on: database)
                .filter(\.$id ~~ container.removedTranslations)
                .delete()
            try await Reference.query(on: database)
                .filter(\.$id ~~ container.removedReferences)
                .delete()
            
            for translation in container.addedTranslations {
                try await Translation(dto: translation).create(on: database)
            }
            
            for translation in container.editedTranslations {
                try await Translation.query(on: database)
                    .filter(\.$id == translation.id)
                    .set(\.$word.$id, to: translation.wordID)
                    .set(\.$translation, to: translation.translation)
                    .set(\.$comment, to: translation.comment)
                    .update()
            }
            
            for reference in container.addedReferences {
                try await Reference(dto: reference).create(on: database)
            }
            
            for reference in container.editedReferences {
                try await Reference.query(on: database)
                    .filter(\.$id == reference.id)
                    .set(\.$source.$id, to: reference.sourceID)
                    .set(\.$destination.$id, to: reference.destinationID)
                    .set(\.$comment, to: reference.comment)
                    .update()
            }
			
			return word.toDTO()
		}
    }

    @Sendable
    func delete(req: Request) async throws -> WordDTO {
        guard let id = req.parameters.get("wordID", as: UUID.self) else {
            throw RequestError.missingQueryProperty("word id")
        }
        
        guard let word = try await Word.find(id, on: req.db) else {
            throw RequestError.requestedModelNotFound(id, type: "word")
        }

        try await word.delete(on: req.db)
        return word.toDTO()
    }
}
