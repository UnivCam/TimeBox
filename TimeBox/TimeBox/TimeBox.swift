//
//  TimeBox.swift
//  TimeBox
//
//  Created by junyng on 2023/08/19.
//

import SwiftUI
import ComposableArchitecture

struct TimeBox: Reducer {
    struct State: Equatable {
        @PresentationState var destination: Destination.State?
        
        var events: IdentifiedArrayOf<Event.State> = [
            Event.State(),
            Event.State(),
            Event.State(),
            Event.State(),
            Event.State(),
            Event.State()
        ]
    }
    
    enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        
        case eventButtonTapped(id: Event.State.ID)
    }
    
    struct Destination: Reducer {
        enum State: Equatable {
            case event(Event.State)
        }
        
        enum Action: Equatable {
            case event(Event.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: /State.event, action: /Action.event) {
                Event()
            }
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .destination(.presented(.event(.confirmButtonTapped))):
                guard case let .event(event) = state.destination else {
                    return .none
                }
                state.events[id: event.id] = event
                return .none
            case .destination:
                return .none
            case .eventButtonTapped(let id):
                guard let event = state.events[id: id] else { return .none }
                state.destination = .event(event)
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
}

struct TimeBoxView: View {
    let store: StoreOf<TimeBox>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ScrollView(.vertical) {
                ZStack(alignment: .top) {
                    VStack(spacing: 0) {
                        ForEach(viewStore.events.map(\.id), id: \.self) { id in
                            Button(action: {
                                viewStore.send(.eventButtonTapped(id: id))
                            }, label: {
                                Rectangle()
                                    .frame(height: 80)
                            })
                            .buttonStyle(EventButtonStyle())
                            .foregroundColor(
                                (viewStore.events[id: id]?.isActive ?? false) ? Color.blue : Color(UIColor.systemGroupedBackground)
                            )
                            .overlay(
                                Text(viewStore.events[id: id]?.description ?? "")
                            )
                        }
                    }
                    .padding(.top, 10)
                    .padding(.leading, 40)
                    
                    VStack(spacing: 60) {
                        ForEach(0...viewStore.events.count + 1, id: \.self) { time in
                            HStack(spacing: 0) {
                                Text("\(time)")
                                    .foregroundColor(.gray)
                                    .frame(width: 40, height: 20, alignment: .trailing)
                                VStack { Divider() }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .sheet(
                store: self.store.scope(state: \.$destination, action: TimeBox.Action.destination),
                state: /TimeBox.Destination.State.event,
                action: TimeBox.Destination.Action.event
            ) { store in
                EventView(store: store)
                    .presentationDetents([.medium])
            }
        }
    }
}

private struct EventButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .border(configuration.isPressed ? .gray : .clear)
    }
}
