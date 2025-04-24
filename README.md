# TAAppCore

## 🚀 Getting started

```swift
import SwiftUI
import TAAppCore

@main
struct MyApp: App {
    @StateObject var reviewRequester =
        ReviewRequester(strategy: .after(days: 120, launches: 15, events: 5))

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(reviewRequester)
                .onAppear {
                    reviewRequester.applicationDidLaunch()
                }
        }
    }
}
```

Trigger the prompt manually from anywhere:

```swift
reviewRequester.requestIfAppropriate()
```

Record positive events (level clear, workout finished, etc.):

```swift
reviewRequester.recordPositiveEvent()
```

---

## 🛠️ Configuration

### Strategies

Build your own with the fluent helpers:

```swift
// Only after 3 days **and** 2 launches
let strict = AnyReviewRequestStrategy.all([
    .after(days: 3),
    .after(launches: 2)
])
```

Or provide a completely custom closure if needed:

```swift
let custom = AnyReviewRequestStrategy { store in
    store.eventsSincePrompt >= 10 && store.lastPromptDate == nil
}
```

### Persistence

```swift
// Use an App Group container for share‑sheet or widget extensions
let store = ReviewRequestStore(suiteName: "group.com.yourcompany.app")
```

### Analytics

Pass any `TAAnalytics` instance to receive two events:

| Event name                | When                                               |
|---------------------------|----------------------------------------------------|
| `REVIEW_REQUEST_TRIGGERED`| Strategy returned `true`; about to call system API |
| `REVIEW_PROMPT_SHOWN`     | After the system prompt is presented               |
