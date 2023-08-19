//
//  Todos.swift
//  TimeBox
//
//  Created by junyng on 2023/08/19.
//

import SwiftUI
import ComposableArchitecture

struct TodosView: View {
    let store: StoreOf<Todos>
    
    var body: some View {
        Text("Todos")
    }
}

struct Todos: Reducer {
    struct State: Equatable {
        
    }
    
    enum Action: Equatable {
        
    }
    
    var body: some Reducer<State, Action> {
        EmptyReducer()
    }
}
