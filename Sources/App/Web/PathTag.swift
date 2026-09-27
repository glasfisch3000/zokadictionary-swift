import Leaf

struct PathTag: LeafTag {
	enum PathTagError: Error {
		case noRequest
	}
	
	func render(_ ctx: LeafContext) throws(PathTagError) -> LeafData {
		guard let request = ctx.request else {
			throw PathTagError.noRequest
		}
		
		var value = request.url.path + (request.url.fragment.map { "#\($0)" } ?? "") + (request.url.query.map { "?\($0)" } ?? "")
		return .string(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value)
	}
}
