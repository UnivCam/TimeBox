//
//  Todo.swift
//  TimeBox
//
//  Created by junyng on 2023/08/19.
//

import SwiftUI
import ComposableArchitecture

struct Todo: Reducer {
    struct State: Equatable, Identifiable {
        let id: UUID
        @BindingState var description: String = ""
        @BindingState var hasPriority: Bool = false
    }
    
    enum Action: BindableAction, Equatable, Sendable {
        case binding(BindingAction<State>)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
    }
}

struct TodoView: View {
    let store: StoreOf<Todo>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            HStack {
                Button {
                    viewStore.$hasPriority.wrappedValue.toggle()
                } label: {
                    Image(systemName: viewStore.hasPriority ? "checkmark.circle" : "circle")
                }
                .buttonStyle(.plain)
                
                TextField("Write down your Todo..", text: viewStore.$description)
            }
            .foregroundColor(viewStore.hasPriority ? .orange : nil)
        }
    }
}
