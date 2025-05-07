import Vapor

struct ErrorMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        do {
            return try await next.respond(to: request)
        } catch let error as any APIError {
            return Response(status: error.httpStatus, body: .init(data: try JSONEncoder().encode(error)))
        }
    }
}

protocol APIError: Error, Encodable {
    associatedtype Code: RawRepresentable<String>
    
    var errorCode: Code { get }
    var errorDescription: String? { get }
    var httpStatus: HTTPResponseStatus { get }
}

private enum _APIErrorDefaultCodingKeys: CodingKey {
    case error
    case description
}

extension APIError {
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: _APIErrorDefaultCodingKeys.self)
        try container.encode(self.errorCode.rawValue, forKey: .error)
        try container.encode(self.errorDescription, forKey: .description)
    }
}


enum RequestError: APIError {
    enum Code: String, Encodable {
        case invalidQuery
        case invalidRequestBody
        case notFound
        case internalError
    }
    
    case missingQueryProperty(String)
    case requestedModelNotFound(UUID, type: String)
    case unableToDecodeBody(type: String)
    case internalError
    
    var errorCode: Code {
        switch self {
        case .missingQueryProperty(_): .invalidQuery
        case .requestedModelNotFound(_, _): .notFound
        case .unableToDecodeBody(_): .invalidRequestBody
        case .internalError: .internalError
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .missingQueryProperty(let string): "missing property: \(string)"
        case .requestedModelNotFound(let id, type: let modelType): "no \(modelType) found for \(id)"
        case .unableToDecodeBody(type: let dataType): "unable to decode \(dataType) from requestBody"
        case .internalError: "an unknown internal error occurred"
        }
    }
    
    var httpStatus: HTTPResponseStatus {
        switch errorCode {
        case .invalidQuery, .invalidRequestBody: .badRequest
        case .notFound: .notFound
        case .internalError: .internalServerError
        }
    }
}
