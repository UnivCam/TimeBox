//
//  Todos.swift
//  TimeBox
//
//  Created by junyng on 2023/08/19.
//

import SwiftUI
import ComposableArchitecture

struct Todos: Reducer {
    struct State: Equatable {
        var todos: IdentifiedArrayOf<Todo.State> = []
    }
    
    enum Action: Equatable {
        case addTodoButtonTapped
        case delete(IndexSet)
        case todo(id: Todo.State.ID, action: Todo.Action)
    }
    
    @Dependency(\.uuid) var uuid
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .addTodoButtonTapped:
                state.todos.append(Todo.State(id: self.uuid()))
                return .none
            case let .delete(indexSet):
                for index in indexSet {
                    state.todos.remove(id: state.todos[index].id)
                }
                return .none
            case .todo:
                return .none
            }
        }
        .forEach(\.todos, action: /Action.todo(id:action:)) {
            Todo()
        }
    }
}

struct TodosView: View {
    let store: StoreOf<Todos>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            List {
                ForEachStore(
                    self.store.scope(state: \.todos, action: Todos.Action.todo(id:action:))
                ) {
                    TodoView(store: $0)
                }
                .onDelete { viewStore.send(.delete($0)) }
                
                Button {
                    viewStore.send(.addTodoButtonTapped)
                } label: {
                    Image(systemName: "plus.circle")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
}
