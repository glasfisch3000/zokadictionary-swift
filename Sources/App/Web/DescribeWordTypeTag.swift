import Leaf

struct DescribeWordTypeTag: LeafTag {
	enum DescribeWordTypeTagError: Error {
		case missingParameter
		case invalidParameter
		case invalidWordType
	}
	
	func render(_ ctx: LeafContext) throws(DescribeWordTypeTagError) -> LeafData {
		guard let arg = ctx.parameters.first else {
			throw .missingParameter
		}
		
		guard let string = arg.string else {
			throw .invalidParameter
		}
		
		guard let wordType = Word.WordType(rawValue: string) else {
			throw .invalidWordType
		}
		
		return .string(wordType.userString)
	}
}
