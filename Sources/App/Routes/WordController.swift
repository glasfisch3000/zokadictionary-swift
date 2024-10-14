import Fluent
import Vapor

struct WordController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let words = routes.grouped("words")

        words.get(use: self.getAll(req:))
        words.post(use: self.create(req:))
        
        words.group(":wordID") { word in
            word.get(use: self.get(req:))
            word.delete(use: self.delete(req:))
        }
    }

    @Sendable
    func getAll(req: Request) async throws -> [WordDTO] {
        try await Word.query(on: req.db).all().map { $0.toDTO() }
    }
    
    @Sendable
    func get(req: Request) async throws -> WordDTO {
        guard let id = req.parameters.get("wordID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "missing word id")
        }
        
        guard let word = try await Word.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        return word.toDTO()
    }

    @Sendable
    func create(req: Request) async throws -> WordDTO {
        let wordDTO = try req.content.decode(WordDTO.self)
        
        let word = wordDTO.toModel()
        try await word.save(on: req.db)
        
        try await word.$references.$pivots.create(wordDTO.references.map { $0.toModel() }, on: req.db)
        try await word.$translations.create(wordDTO.translations.map { $0.toModel() }, on: req.db)
        
        return word.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let word = try await Word.find(req.parameters.get("wordID"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await word.delete(on: req.db)
        return .ok
    }
}
