# ReduxStore

Redux Architecture Library 

# Installation 

```bash
https://github.com/paigeshin/SwiftReduxStore
```

# Version Support

iOS 13++
macOS 10_15_5

# Sample Projects

[Sample Project](https://github.com/paigeshin/ReduxSampleProject)

# What is Redux Architecture?

Declarative Framework has a lot of nested views by its nature. It's cumbersome whenever you have to pass state argument. Your code base becomes easily nasty.
So Redux Architecture has come to a rescue by leveraring `AppState` Concept. Instead of Local State in each view, you can manage global state. You don't ever need to pass arguments to the nested views. It will be managed by `ReduxStore` from this library.

 
# Simple Redux Usage - Counter Example 

### States

```swift

struct AppState: ReduxState {
    var countState: CountState = CountState()
}

struct CountState {
    var count: Int = 0
}

```

AppState must contain all states you need in your project.
Because I'm building Counter App, I defined `CounterState` here. 
`AppState` has `CounterState` as its property.

### Actions 

```

struct Increment: Action {}

struct Decrement: Action {}

```

Each of your state has actions to change its state. 
In this example, you only have two actions. Increment count, Decrement Count.

### Reducers 

```

func appReducer(_ state: AppState, _ action: Action) -> AppState {
    var state: AppState = state
    state.countState = counterReducer(state.countState, action)
    return state
}

func counterReducer(_ state: CountState, _ action: Action) -> CountState {
    var state: CountState = state
    switch action {
    case _ as Increment:
        state.count += 1
    case _ as Decrement:
        state.count -= 1
    default:
        return state
    }
    return state
}

```

Reducer is where actual modifications on states happen. 
`appReducer` must contain all reducers which modify states.
`counterReduer` handles all the logics related with `CounterState`.

### Initialize Your Store

```
import SwiftUI
import ReduxStore

@main
struct TestApp: App {
    
    @StateObject private var store: Store = Store(reducer: appReducer, state: AppState(), middlewares: [])
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
```

On your root view initialize store with `appReducer` and `AppState()`.

### Map ReduxStore with Props on view.

```swift
import SwiftUI
import ReduxStore

struct ContentView: View {
    
    @EnvironmentObject var store: Store<AppState>
    
    private struct Props {
        let increment: () -> Void
        let decrement: () -> Void
        let count: Int
    }
    
    private func map() -> Props {
        Props(
            increment: {store.dispatch(action: Increment())},
            decrement: {store.dispatch(action: Decrement())},
            count: store.state.countState.count
        )
    }
    
    var body: some View {
        let props: Props = map()
        VStack {
            
            Text("\(props.count)")
            
            Button {
                props.increment()
            } label: {
                Text("Increment")
            }

            Button {
                props.decrement()
            } label: {
                Text("Decrement")
            }
        }
    }
}
```

You can directly use `store.dispatch(action: Increment())` without mapping. It's your choice. 
Your counter app is done now!. 

# Middleware

### Create Middleware

```swift
func logMiddleware() -> Middleware<AppState> {
    return { state, action, dispatch in
        print("LOG MIDDLEWARE")
    }
}
```

Middleware is called whenever actions from reducer are taken. I created logMiddleware() to keep following all the actions in my project.

 
### Attach Middleware

```swift
@main
struct TestApp: App {
    
    @StateObject private var store: Store = Store(reducer: appReducer, state: AppState(), middlewares: [
        logMiddleware()
    ])
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
```

You can attach middleware when you initialize `store`.

# Asynchronous Task

### Define your middleware 

```swift

struct IncrementAsync: Action { }

func incrementMiddleware() -> Middleware<AppState> {
    return { state, action, dispatch in
        switch action {
        case _ as IncrementAsync:
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                dispatch(Increment())
            }
        default:
            break
        }
    }
}

```

Asynchronous Task is achieved by Middleware. Network calls are handled by middlewares.

### Attach it on your root view 

```swift

@main
struct TestApp: App {
    
    @StateObject private var store: Store = Store(reducer: appReducer, state: AppState(), middlewares: [
        logMiddleware(),
        incrementMiddleware()
    ])
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}

``` 

Provide your middleware.

### Use it on view

```swift
struct ContentView: View {
    
    @EnvironmentObject var store: Store<AppState>
    
    private struct Props {
        let increment: () -> Void
        let decrement: () -> Void
        let incrementAsync: () -> Void
        let count: Int
    }
    
    private func map() -> Props {
        Props(
            increment: {store.dispatch(action: Increment())},
            decrement: {store.dispatch(action: Decrement())},
            incrementAsync: {store.dispatch(action: IncrementAsync())},
            count: store.state.countState.count
        )
    }
    
    var body: some View {
        let props: Props = map()
        VStack {
            
            Text("\(props.count)")
            
            Button {
                props.incrementAsync()
            } label: {
                Text("Increment Async")
            }
            
            Button {
                props.increment()
            } label: {
                Text("Increment")
            }

            Button {
                props.decrement()
            } label: {
                Text("Decrement")
            }
        }
    }
}
```

Through `Async Action` you defined, you can now handle asynchronous task in your project.
