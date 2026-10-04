import Vapor
import FluentPostgresDriver

struct ErrorMiddleware: AsyncMiddleware {
	func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
		do throws(WebError) {
			return try await withMappingErrors {
				try await next.respond(to: request)
			}
		} catch let error {
			return switch error {
			case .auth(let authError): handleAuthError(authError, request: request)
			default: throw error
			}
		}
	}
	
	func handleAuthError(_ error: AuthError, request: Request) -> Response {
		let query = request.url
			.string
			.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
			.flatMap { "return=\($0)" }
		
		return request.redirect(to: "/login?error=\(error.rawValue)&\(query ?? "")")
	}
}

private func withMappingErrors<T>(_ closure: () async throws -> T) async throws(WebError) -> T {
	let env = (try? Environment.detect()) ?? .production
	let debug = env.name == "testing"
	
	do {
		return try await closure()
	} catch let error as WebError {
		throw error
	} catch let error as AuthError {
		throw .auth(error)
	} catch let error as PSQLError {
		if debug {
			throw .internalError
		} else {
			throw .other(debugInfo: error.debugDescription)
		}
	} catch let error as DecodingError {
		if debug {
			throw .malformedRequest
		} else {
			throw .other(debugInfo: error.localizedDescription)
		}
	} catch let error as Abort {
		switch error.status {
		// vapor throws this when required url parameters can't be parsed correctly
		case .unprocessableEntity: throw .malformedRequest
		// vapor throws this when a required login doesn't exist
		case .unauthorized: throw .auth(.missingLogin)
		case .notFound: throw .notFound
		default:
			if debug {
				throw .internalError
			} else {
				throw .other(debugInfo: error.debugDescription)
			}
		}
	} catch _ as RouteNotFound {
		throw .notFound
	} catch let error {
		if debug {
			throw .internalError
		} else {
			throw .other(debugInfo: error.localizedDescription)
		}
	}
}
