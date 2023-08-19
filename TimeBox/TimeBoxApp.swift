//
//  TimeBoxApp.swift
//  TimeBox
//
//  Created by junyng on 2023/08/19.
//

import SwiftUI
import ComposableArchitecture

@main
struct TimeBoxApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(
                store: .init(
                    initialState: AppFeature.State.init(
                        todos: Todos.State(),
                        timebox: TimeBox.State(),
                        selectedTab: .todos
                    )
                ) {
                    AppFeature()
                }
            )
        }
    }
}

struct AppView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            TabView(
                selection: viewStore.binding(get: \.selectedTab, send: AppFeature.Action.tabSelected)
            ) {
                TodosView(
                    store: self.store.scope(state: \.todos, action: AppFeature.Action.todos)
                )
                .tabItem { Label(AppFeature.Tab.todos.title, systemImage: AppFeature.Tab.todos.systemImageName) }
                .tag(AppFeature.Tab.todos)
                TimeBoxView(
                    store: self.store.scope(state: \.timebox, action: AppFeature.Action.timebox)
                )
                .tabItem { Label(AppFeature.Tab.timebox.title, systemImage: AppFeature.Tab.timebox.systemImageName) }
                .tag(AppFeature.Tab.timebox)
            }
        }
    }
}

struct AppFeature: Reducer {
    enum Tab { case todos, timebox }
    struct State: Equatable {
        var todos: Todos.State
        var timebox: TimeBox.State
        var selectedTab: Tab
    }
    
    enum Action: Equatable {
        case tabSelected(Tab)
        case todos(Todos.Action)
        case timebox(TimeBox.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.todos, action: /Action.todos) {
            Todos()
        }
        Scope(state: \.timebox, action: /Action.timebox) {
            TimeBox()
        }
        Reduce { state, action in
            switch action {
            case .tabSelected(let tab):
                state.selectedTab = tab
                return .none
            case .todos:
                return .none
            case .timebox:
                return .none
            }
        }
    }
}

extension AppFeature.Tab {
    var title: String {
        switch self {
        case .todos:
            return "Todos"
        case .timebox:
            return "TimeBox"
        }
    }
    
    var systemImageName: String {
        switch self {
        case .todos:
            return "checklist"
        case .timebox:
            return "timer.square"
        }
    }
}
