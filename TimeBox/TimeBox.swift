//
//  TimeBox.swift
//  TimeBox
//
//  Created by junyng on 2023/08/19.
//

import SwiftUI
import ComposableArchitecture

struct TimeBoxView: View {
    let store: StoreOf<TimeBox>
    
    var body: some View {
        Text("TimeBox")
    }
}

struct TimeBox: Reducer {
    struct State: Equatable {
        
    }
    
    enum Action: Equatable {
        
    }
    
    var body: some Reducer<State, Action> {
        EmptyReducer()
    }
}
