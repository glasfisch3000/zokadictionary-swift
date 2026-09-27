import Vapor

enum WebError: Error {
	// authentication errors
	
	case auth(AuthError)
	case forbidden
	
	// request errors
	case malformedRequest
	case notFound
	case payloadTooLarge
	case searchStringTooLarge
	
	// server errors
	case internalError
}
