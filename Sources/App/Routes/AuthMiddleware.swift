import Vapor
import Fluent

struct AuthMiddleware: AsyncRequestAuthenticator {
    var requiresMaintainer: Bool
    
    init(requiresMaintainer: Bool) {
        self.requiresMaintainer = requiresMaintainer
    }
    
    func authenticate(request: Request) async throws(AuthenticationError) {
        guard let auth = request.headers.basicAuthorization else {
            throw .missing
        }
        
        guard let user = try? await User.query(on: request.db)
            .filter(\.$name == auth.username)
            .first() else {
            throw .invalid
        }
        
        if self.requiresMaintainer {
            switch user.type {
            case .viewer: throw .disallowed
            case .maintainer: break
            }
        }
        
        guard user.password == User.hashPassword(auth.password, salt: user.salt) else {
            throw .invalid
        }
    }
}

enum AuthenticationError: String, APIError {
    case missing = "missingAuthentication"
    case invalid = "invalidAuthentication"
    case disallowed
    
    var errorCode: Self { self }
    var errorDescription: String? { nil }
    
    var httpStatus: HTTPResponseStatus {
        switch self {
        case .missing, .invalid: .unauthorized
        case .disallowed: .forbidden
        }
    }
}
