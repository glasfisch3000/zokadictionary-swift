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

enum AuthenticationError: String, Error, Encodable {
    case missing
    case invalid
    case disallowed
}
