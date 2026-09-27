import Vapor
import struct Foundation.UUID

struct Identified<T>: Identifiable {
	var id: UUID
	var value: T
}

extension Identified: Equatable where T: Equatable { }
extension Identified: Hashable where T: Hashable { }
extension Identified: Sendable where T: Sendable { }
extension Identified: Encodable where T: Encodable { }
extension Identified: Decodable where T: Decodable { }
extension Identified: Content, RequestDecodable, AsyncRequestDecodable, ResponseEncodable, AsyncResponseEncodable where T: Codable { }
