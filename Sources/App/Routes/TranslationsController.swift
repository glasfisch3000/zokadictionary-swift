import Fluent
import Vapor
import PostgresNIO

struct TranslationsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: self.getAll(req:))
        routes.grouped(AuthMiddleware(requiresMaintainer: true)).post(use: self.create(req:))
        
        routes.group(":translationID") { translation in
            translation.get(use: self.get(req:))
			
            let authTranslation = translation.grouped(AuthMiddleware(requiresMaintainer: true))
			authTranslation.delete(use: self.delete(req:))
        }
    }

    @Sendable
    func getAll(req: Request) async throws -> [TranslationDTO] {
        var query = Translation.query(on: req.db)
            .with(\.$word)
        
        if let wordID = req.query[UUID.self, at: "wordID"] {
            query = query.filter(\.$word.$id == wordID)
        }
        
        return try await query
            .all()
            .map { $0.toDTO() }
    }
    
    @Sendable
    func get(req: Request) async throws -> TranslationDTO {
        guard let id = req.parameters.get("translationID", as: UUID.self) else {
            throw RequestError.missingQueryProperty("translation id")
        }
        
        guard let translation = try await Translation.find(id, on: req.db) else {
            throw RequestError.requestedModelNotFound(id, type: "translation")
        }
        
        return translation.toDTO()
    }

    @Sendable
    func create(req: Request) async throws -> TranslationDTO {
        let translationDTO = try req.content.decode(TranslationDTO.self)
        
        let translation = Translation(dto: translationDTO)
        try await translation.save(on: req.db)
        
        return translation.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> TranslationDTO {
        guard let id = req.parameters.get("translationID", as: UUID.self) else {
            throw RequestError.missingQueryProperty("translation id")
        }
        
        guard let translation = try await Translation.find(id, on: req.db) else {
            throw RequestError.requestedModelNotFound(id, type: "translation")
        }

        try await translation.delete(on: req.db)
        return translation.toDTO()
    }
}
