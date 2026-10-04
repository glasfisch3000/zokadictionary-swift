import Vapor
import Fluent

extension WebRoutes {
	private struct IndexContext: Encodable {
		var user: Identified<User.DTO>?
		var words: [Identified<Word.DTOWithIdentifiedRelations>]
		
		var search: String?
		var deleted: Bool
	}
	
	func index(req: Request) async throws -> View {
		let user = req.auth.get(User.self)
		let searchString = try req.query.get(String?.self, at: "search")
		let deleted = try req.query.get(Bool?.self, at: "deleted") ?? false
		
		if deleted {
			guard let user else {
				throw AuthError.missingLogin
			}
			guard user.type == .admin || user.type == .contributor else {
				throw WebError.forbidden
			}
		}
		
		let query = if deleted {
			Word.query(on: req.db)
				.withDeleted()
				.filter(\.$deleted != nil)
				.with(\.$references, withDeleted: true) {
					$0.with(\.$destination, withDeleted: true)
				}
				.with(\.$backReferences, withDeleted: true) {
					$0.with(\.$source, withDeleted: true)
				}
				.with(\.$translations, withDeleted: true)
		} else {
			Word.query(on: req.db)
				.with(\.$references) {
					$0.with(\.$destination)
				}
				.with(\.$translations)
		}
		
		if let searchString {
			if searchString.count > 100 {
				throw WebError.searchStringTooLarge
			}
			
			let words = try await query.all()
			
			guard let results = try await search(searchString, in: words) else {
				return try await renderIndex(user: user, words: [], search: searchString, deleted: deleted, req: req)
			}
			
			if results.isEmpty {
				return try await renderIndex(user: user, words: [], search: searchString, deleted: deleted, req: req)
			}
			
			return try await renderIndex(user: user, words: results, search: searchString, deleted: deleted, req: req)
		} else {
			let words = try await query
				.sort(\.$string, .ascending)
				.sort(\.$type, .ascending)
				.sort(\.$id, .ascending)
				.all()
			
			return try await renderIndex(user: user, words: words, deleted: deleted, req: req)
		}
	}
	
	private func renderIndex(user: User?, words: [Word], search: String? = nil, deleted: Bool, req: Request) async throws -> View {
		let context = IndexContext(
			user: try user?.toDTO(),
			words: try words.map { try $0.toDTOWithIdentifiedRelations() },
			search: search,
			deleted: deleted,
		)
		
		return try await req.view.render("Pages/index", context)
	}
	
	func getSearch(req: Request) async throws -> [Identified<Word.DTOWithIdentifiedRelations>] {
		let user = req.auth.get(User.self)
		let searchString = try req.query.get(String?.self, at: "search")
		let deleted = try req.query.get(Bool?.self, at: "deleted") ?? false
		
		if deleted {
			guard let user else {
				throw AuthError.missingLogin
			}
			guard user.type == .admin || user.type == .contributor else {
				throw WebError.forbidden
			}
		}
		
		let results: [Word]
		let query = if deleted {
			Word.query(on: req.db)
				.withDeleted()
				.filter(\.$deleted != nil)
				.with(\.$references, withDeleted: true) {
					$0.with(\.$destination, withDeleted: true)
				}
				.with(\.$translations, withDeleted: true)
		} else {
			Word.query(on: req.db)
				.with(\.$references) {
					$0.with(\.$destination)
				}
				.with(\.$translations)
		}
		
		if let searchString {
			if searchString.count > 100 {
				throw Abort(.badRequest)
			}
			
			let words = try await query.all()
			
			results = try await search(searchString, in: words) ?? []
		} else {
			results = try await query.all()
		}
		
		return try results.map { try $0.toDTOWithIdentifiedRelations() }
	}
}

extension WebRoutes {
	func search(_ search: String, in allWords: [Word]) async throws -> [Word]? {
		struct Match {
			var word: Word
			var score: Int
		}
		
		let tokens = tokenize(search)
		if tokens.isEmpty {
			return nil
		}
		
		var matches = [Match]()
		
		word_loop: for word in allWords {
			var bestMatch = 0
			var tokenIndex = 0
			
			while tokenIndex < tokens.count {
				guard let match = findMatch(tokens, index: &tokenIndex, word: word) else {
					continue word_loop
				}
				
				bestMatch = max(bestMatch, match)
			}
			
			matches.append(Match(word: word, score: bestMatch))
		}
		
		return matches
			.sorted {
				if $0.score < $1.score { return true }
				if $1.score < $0.score { return false }
				return $0.word < $1.word
			}
			.map(\.word)
	}
	
	// returns the length of the best match
	private func findMatch(_ tokens: [Substring], index tokenIndex: inout Int, word: Word) -> Int? {
		enum Match {
			case string(start: Int, end: Int)
			case translation(start: Int, end: Int)
			case reference(start: Int, end: Int)
			case type(start: Int, end: Int)
			
			var length: Int {
				switch self {
				case .string(let start, let end): end - start
				case .translation(let start, let end): end - start
				case .reference(let start, let end): end - start
				case .type(let start, let end): end - start
				}
			}
		}
		
		// tokenize the word's attributes
		let string = tokenize(word.string)
		let translations = word.$translations.value?.map(\.translation).flatMap(tokenize(_:)) ?? []
		let references = word.$references.value?.compactMap(\.$destination.value?.string).flatMap(tokenize(_:)) ?? []
		let type = tokenize(word.type.userString)
		
		var matches = [Match]()
		var bestMatchLength = 1
		
		// add initial matches
		matches += string
			.indexed()
			.compactMap { index, element -> Match? in
				guard element.starts(with: tokens[tokenIndex]) else {
					return nil
				}
				
				return Match.string(start: index, end: index+1)
			}
		matches += translations
			.indexed()
			.compactMap { index, element -> Match? in
				guard element.starts(with: tokens[tokenIndex]) else {
					return nil
				}
				
				return Match.translation(start: index, end: index+1)
			}
		matches += type
			.indexed()
			.compactMap { index, element -> Match? in
				guard element.starts(with: tokens[tokenIndex]) else {
					return nil
				}
				
				return Match.type(start: index, end: index+1)
			}
		matches += references
			.indexed()
			.compactMap { index, element -> Match? in
				guard element.starts(with: tokens[tokenIndex]) else {
					return nil
				}
				
				return Match.reference(start: index, end: index+1)
			}
		
		// if there are no intial matches, abort
		if matches.isEmpty {
			return nil
		}
		
		// start with the next token. the current one has been checked already
		tokenIndex += 1
		while tokenIndex < tokens.count {
			for (index, match) in matches.indexed() {
				// check if each match can be expanded to the next token
				switch match {
				case .string(let start, let end):
					guard end < string.count else { continue }
					guard string[end].starts(with: tokens[tokenIndex]) else { continue }
					matches[index] = .string(start: start, end: end+1)
				case .translation(let start, let end):
					guard end < translations.count else { continue }
					guard translations[end].starts(with: tokens[tokenIndex]) else { continue }
					matches[index] = .translation(start: start, end: end+1)
				case .reference(let start, let end):
					guard end < references.count else { continue }
					guard references[end].starts(with: tokens[tokenIndex]) else { continue }
					matches[index] = .reference(start: start, end: end+1)
				case .type(let start, let end):
					guard end < type.count else { continue }
					guard type[end].starts(with: tokens[tokenIndex]) else { continue }
					matches[index] = .type(start: start, end: end+1)
				}
			}
			
			// remove outdated matches
			matches.removeAll { $0.length <= bestMatchLength }
			
			// if there are no matches left, return
			if matches.isEmpty {
				return bestMatchLength
			}
			
			tokenIndex += 1
			bestMatchLength += 1
		}
		
		return bestMatchLength
	}
	
	private func tokenize(_ string: String) -> [Substring] {
		string
			.lowercased()
			.split(separator: /[\n\t ,;.…:_\-–—~()\[\]{}\/\\|"„““”''‘’´`+*#?¿!¡&%$§<>]/)
			.filter { !$0.isEmpty }
	}
}
