//
//  FileClient.swift
//  TimeBox
//
//  Created by junyng on 2023/08/20.
//

import Foundation

struct FileClient {
    var delete: @Sendable (String) async throws -> Void
    var load: @Sendable (String) async throws -> Data
    var save: @Sendable (String, Data) async throws -> Void
    
    func load<A: Decodable>(_ type: A.Type, from fileName: String) async throws -> A {
        try await JSONDecoder().decode(A.self, from: self.load(fileName))
    }
    
    func save<A: Encodable>(_ data: A, to fileName: String) async throws {
        try await self.save(fileName, JSONEncoder().encode(data))
    }
}
