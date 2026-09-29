function describeWordType(wordType) {
	switch (wordType) {
		case "adjective": return "adjective"
		case "noun": return "noun"
		case "number": return "number"
		case "particle": return "particle"
		case "preposition": return "preposition"
		case "questionWord": return "question word"
		case "verb": return "verb"
		default: return "other"
	}
}
