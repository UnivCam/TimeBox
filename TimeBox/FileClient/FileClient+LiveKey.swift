//
//  FileClient+LiveKey.swift
//  TimeBox
//
//  Created by junyng on 2023/08/20.
//

import Dependencies
import Foundation

extension DependencyValues {
    var fileClient: FileClient {
        get { self[FileClient.self] }
        set { self[FileClient.self] = newValue }
    }
}

extension FileClient: DependencyKey {
    static let liveValue = {
        let documentDirectory = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
        
        return Self(
            delete: {
                try FileManager.default.removeItem(
                    at: documentDirectory.appendingPathComponent($0).appendingPathExtension("json")
                )
            },
            load: {
                try Data(
                    contentsOf: documentDirectory.appendingPathComponent($0).appendingPathExtension("json")
                )
            },
            save: {
                try $1.write(
                    to: documentDirectory.appendingPathComponent($0).appendingPathExtension("json")
                )
            }
        )
    }()
}
