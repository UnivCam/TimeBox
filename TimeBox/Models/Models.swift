//
//  Models.swift
//  TimeBox
//
//  Created by junyng on 2023/08/20.
//

import Foundation

enum Models {}

extension Models {
    struct TimeBox: Codable, Equatable {
        let todos: [Todo]
        let events: [Event]
    }
    
    struct Todo: Codable, Equatable {
        let description: String
        let hasPriority: Bool
    }
    
    struct Event: Codable, Equatable {
        let description: String
        let startDate: Date
        let endDate: Date
        let isActive: Bool
    }
}
