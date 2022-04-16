import Foundation

public typealias Dispatcher = (Action) -> Void
public typealias Reducer<State: ReduxState> = (_ state: State, _ action: Action) -> State
public typealias Middleware<StoreState: ReduxState> = (StoreState, Action, @escaping Dispatcher) -> Void

public protocol ReduxState { }
public protocol Action { }

public class Store<StoreState: ReduxState>: ObservableObject {

    var reducer: Reducer<StoreState>
    @Published public var state: StoreState
    var middlewares: [Middleware<StoreState>]

    public init(reducer: @escaping Reducer<StoreState>,
         state: StoreState,
         middlewares: [Middleware<StoreState>] = []) {
        self.reducer = reducer
        self.state = state
        self.middlewares = middlewares
    }

    public func dispatch(action: Action) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.state = self.reducer(self.state, action)
        }

        // run all middlewares
        middlewares.forEach { middleware in
            middleware(state, action, dispatch)
        }

    }

}
