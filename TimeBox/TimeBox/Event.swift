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
        @BindingState var tagColor: String? = nil
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
                fallthrough
            case .confirmButtonTapped:
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
                VStack(alignment: .leading) {
                    TextField("Title..", text: viewStore.$description)

                    Divider()
                    
                    Section {
                        ColorPanel(
                            colors: .constant(.default),
                            selection: Binding<Color?>(
                                get: { Color(hex: viewStore.tagColor ?? "") },
                                set: { color in
                                    viewStore.send(.binding(.set(\.$tagColor, color?.toHex())))
                                }
                            )
                        )
                    } header: {
                        Text("Color Tag")
                            .bold()
                    }

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
