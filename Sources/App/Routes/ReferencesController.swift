import Fluent
import Vapor
import PostgresNIO

struct ReferencesController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: self.getAll(req:))
        routes.grouped(AuthMiddleware(requiresMaintainer: true)).post(use: self.create(req:))
        
        routes.group(":referenceID") { reference in
            reference.get(use: self.get(req:))
            reference.grouped(AuthMiddleware(requiresMaintainer: true)).delete(use: self.delete(req:))
        }
    }

    @Sendable
    func getAll(req: Request) async throws -> [ReferenceDTO] {
        var query = Reference.query(on: req.db)
            .with(\.$source)
            .with(\.$destination)
        
        if let sourceID = req.query[UUID.self, at: "sourceID"] {
            query = query.filter(\.$source.$id == sourceID)
        }
        
        if let destinationID = req.query[UUID.self, at: "destinationID"] {
            query = query.filter(\.$destination.$id == destinationID)
        }
		
		if let deleted = req.query[Bool.self, at: "deleted"], deleted {
			query = query.withDeleted()
				.filter(\.$deleted != nil)
		}
        
        return try await query
            .all()
            .map { $0.toDTO() }
    }
    
    @Sendable
    func get(req: Request) async throws -> ReferenceDTO {
        guard let id = req.parameters.get("referenceID", as: UUID.self) else {
            throw RequestError.missingQueryProperty("reference id")
        }
        
        guard let reference = try await Reference.find(id, on: req.db) else {
            throw RequestError.requestedModelNotFound(id, type: "reference")
        }
        
        return reference.toDTO()
    }

    @Sendable
    func create(req: Request) async throws -> ReferenceDTO {
        let referenceDTO = try req.content.decode(ReferenceDTO.self)
        
        let reference = Reference(dto: referenceDTO)
        try await reference.save(on: req.db)
        
        return reference.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> ReferenceDTO {
        guard let id = req.parameters.get("reference", as: UUID.self) else {
            throw RequestError.missingQueryProperty("reference id")
        }
        
        guard let reference = try await Reference.find(id, on: req.db) else {
            throw RequestError.requestedModelNotFound(id, type: "reference")
        }

        try await reference.delete(on: req.db)
        return reference.toDTO()
    }
}
