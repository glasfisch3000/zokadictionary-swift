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
	
	do {
		return try await closure()
	} catch let error as WebError {
		throw error
	} catch let error as AuthError {
		throw .auth(error)
	} catch let error as PSQLError {
		if env.isRelease {
			throw .internalError
		} else {
			throw .other(debugInfo: error.debugDescription)
		}
	} catch let error as DecodingError {
		if env.isRelease {
			throw .malformedRequest
		} else {
			throw .other(debugInfo: error.localizedDescription)
		}
	} catch let error as Abort where error.status == .unprocessableEntity {
		// vapor throws this when required url parameters can't be parsed correctly
		throw .malformedRequest
	} catch let error as Abort where error.status == .unauthorized {
		// vapor throws this when a required login doesn't exist
		throw .auth(.missingLogin)
	} catch let error {
		if env.isRelease {
			throw .internalError
		} else {
			throw .other(debugInfo: error.localizedDescription)
		}
	}
}
