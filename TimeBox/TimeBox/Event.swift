//
//  Event.swift
//  TimeBox
//
//  Created by junyng on 2023/08/19.
//

import SwiftUI
import ComposableArchitecture

struct Event: Reducer {
    struct State: Equatable, Identifiable {
        let id: UUID = UUID()
        @BindingState var description: String = ""
        var isActive: Bool = false
    }
    
    enum Action: BindableAction, Equatable, Sendable {
        case binding(BindingAction<State>)
        case cancelButtonTapped
        case confirmButtonTapped
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .cancelButtonTapped:
                state.isActive = false
                return .run { _ in
                    await dismiss()
                }
            case .confirmButtonTapped:
                state.isActive = true
                return .run { _ in
                    await dismiss()
                }
            }
        }
    }
}

struct EventView: View {
    let store: StoreOf<Event>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                VStack {
                    TextField("Write down your Todo..", text: viewStore.$description)
                    Spacer()
                }
                .padding()
                .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            viewStore.send(.cancelButtonTapped)
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Confirm") {
                            viewStore.send(.confirmButtonTapped)
                        }
                    }
                }
            }
        }
    }
}
