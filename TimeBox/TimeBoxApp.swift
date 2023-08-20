//
//  TimeBoxApp.swift
//  TimeBox
//
//  Created by junyng on 2023/08/19.
//

import SwiftUI
import ComposableArchitecture

final class AppDelegate: NSObject, UIApplicationDelegate {
    let store = Store(
        initialState: AppFeature.State.init(
            todos: Todos.State(),
            timebox: TimeBox.State(),
            selectedTab: .todos
        )
    ) {
        AppFeature().transformDependency(\.self) {
            $0.fileClient = .liveValue
        }
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        self.store.send(.appDelegate(.didFinishLaunching))
        return true
    }
}

@main
struct TimeBoxApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            AppView(store: self.appDelegate.store)
        }
        .onChange(of: self.scenePhase) {
            self.appDelegate.store.send(.didChangeScenePhase($0))
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
    
    enum AppDelegateAction: Equatable {
        case didFinishLaunching
    }
    
    enum Action: Equatable {
        case appDelegate(AppDelegateAction)
        case didChangeScenePhase(ScenePhase)
        case timeBoxLoaded(TaskResult<Models.TimeBox>)
        case tabSelected(Tab)
        case todos(Todos.Action)
        case timebox(TimeBox.Action)
    }
    
    @Dependency(\.fileClient) var fileClient
    @Dependency(\.date) var date
    
    var body: some Reducer<State, Action> {
        Scope(state: \.todos, action: /Action.todos) {
            Todos()
        }
        Scope(state: \.timebox, action: /Action.timebox) {
            TimeBox()
        }
        Reduce { state, action in
            switch action {
            case .appDelegate(.didFinishLaunching):
                return .run { send in
                    await send(
                        .timeBoxLoaded(
                            TaskResult { try await fileClient.load(Models.TimeBox.self, from: dateFormatter.string(from: date())) }
                        )
                    )
                }
            case .didChangeScenePhase(let scenePhase):
                guard case .background = scenePhase else { return .none }
                let todos = state.todos.todos.map { Models.Todo(description: $0.description, hasPriority: $0.hasPriority) }
                let events = state.timebox.events.map { Models.Event(description: $0.description, startDate: date(), endDate: date(), isActive: $0.isActive) }
                let timeBox = Models.TimeBox(todos: todos, events: events)
                return .run { _ in
                    try await fileClient.save(timeBox, to: dateFormatter.string(from: date()))
                }
            case .timeBoxLoaded(.success(let timeBox)):
                state.todos.todos = IdentifiedArray(
                    uniqueElements: timeBox.todos.map { Todo.State(description: $0.description, hasPriority: $0.hasPriority) }
                )
                state.timebox.events = IdentifiedArray(
                    uniqueElements: timeBox.events.map { Event.State(description: $0.description, isActive: $0.isActive) }
                )
                return .none
            case .timeBoxLoaded(.failure):
                state.timebox.events = [
                    Event.State(), Event.State(), Event.State(),
                    Event.State(), Event.State(), Event.State(),
                    Event.State(), Event.State(), Event.State(),
                    Event.State(), Event.State(), Event.State(),
                    Event.State(), Event.State(), Event.State()
                ]
                return .none
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

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()
