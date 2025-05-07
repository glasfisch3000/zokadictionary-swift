import Fluent
import Vapor
import PostgresNIO

struct WordController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: self.getAll(req:))
        routes.grouped(AuthMiddleware(requiresMaintainer: true)).post(use: self.create(req:))
        
        routes.group(":wordID") { word in
            word.get(use: self.get(req:))
            word.grouped(AuthMiddleware(requiresMaintainer: true)).delete(use: self.delete(req:))
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
        let wordDTO = try req.content.decode(WordDTO.self)
        
        let word = Word(dto: wordDTO)
        try await word.save(on: req.db)
        
        try await word.$references.create(wordDTO.references.map(Reference.init(dto:)), on: req.db)
        try await word.$translations.create(wordDTO.translations.map(Translation.init(dto:)), on: req.db)
        
        return word.toDTO()
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
