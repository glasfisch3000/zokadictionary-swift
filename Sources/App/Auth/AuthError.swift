enum AuthError: String, Error, Hashable, Codable {
	/// The user should log in.
	case missingLogin
	/// The login data provided by the user is invalid or wrong.
	case invalidLoginData
	/// The session token provided by the user is invalid or wrong.
	case invalidSession
}
