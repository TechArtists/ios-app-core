//
//  ReviewRequester.swift
//  TAAppCore
//
//  Created by Robert Tataru on 20.04.2025.
//

import SwiftUI
import Foundation
import StoreKit
import UIKit
import TAAnalytics

@MainActor
public final class ReviewRequester: ObservableObject {

    public struct State: Equatable, Sendable {
        public let lastPromptDate: Date?
        public let launchesSincePrompt: Int
        public let eventsSincePrompt: Int
        public let isEligibleForRequest: Bool

        public init(
            lastPromptDate: Date?,
            launchesSincePrompt: Int,
            eventsSincePrompt: Int,
            isEligibleForRequest: Bool
        ) {
            self.lastPromptDate = lastPromptDate
            self.launchesSincePrompt = launchesSincePrompt
            self.eventsSincePrompt = eventsSincePrompt
            self.isEligibleForRequest = isEligibleForRequest
        }
    }

    private let store: ReviewRequestStore
    private let strategy: ReviewRequestStrategy
    public var analytics: TAAnalytics?
    @Published public private(set) var state: State

    /// Inject a custom store for tests or AppGroup setups.
    public init(
        store: ReviewRequestStore = .standard,
        strategy: ReviewRequestStrategy = AnyReviewRequestStrategy.after(days: 120, launches: 15, events: 5),
        analytics: TAAnalytics? = nil
    ) {
        self.store = store
        self.strategy = strategy
        self.analytics = analytics
        self.state = Self.makeState(store: store, strategy: strategy)
    }

    // MARK: Public API
    /// Records a launch & attempts to show the prompt if the `strategy` permits.
    /// – Call early in `scene(_:willConnectTo:options:)` or `applicationDidFinishLaunching`.
    public func applicationDidLaunch() {
        store.recordLaunch()
        refreshState()
    }

    /// Manually record a positive in‑app event (level clear, workout finished, etc.).
    public func recordPositiveEvent() {
        store.recordEvent()
        refreshState()
    }

    /// Attempts to display a prompt if the given strategy evaluates to `true`.
    @discardableResult
    public func requestIfAppropriate() -> Bool {
        refreshState()
        guard state.isEligibleForRequest else { return false }

        analytics?.track(event: .init(EventAnalyticsModel.REVIEW_REQUEST_TRIGGERED.rawValue), params: [
            "strategy_type": String(describing: strategy)
        ])
        performSystemRequest()
        analytics?.track(event: .init(EventAnalyticsModel.REVIEW_PROMPT_SHOWN.rawValue), params: [
            "strategy_type": String(describing: strategy)
        ])
        store.recordPromptShown()
        refreshState()
        return true
    }

    public func reload() {
        refreshState()
    }

    // MARK: System interaction
    private func performSystemRequest() {
        guard let scene = UIApplication.shared.connectedScenes
                .first(where: { ($0 as? UIWindowScene)?.activationState == .foregroundActive }) as? UIWindowScene else { return }
        SKStoreReviewController.requestReview(in: scene)
    }

    private func refreshState() {
        let updatedState = Self.makeState(store: store, strategy: strategy)
        guard state != updatedState else { return }
        state = updatedState
    }

    private static func makeState(store: ReviewRequestStore, strategy: ReviewRequestStrategy) -> State {
        State(
            lastPromptDate: store.lastPromptDate,
            launchesSincePrompt: store.launchesSincePrompt,
            eventsSincePrompt: store.eventsSincePrompt,
            isEligibleForRequest: strategy.shouldRequestReview(using: store)
        )
    }
}


extension ReviewRequester {
    
    enum EventAnalyticsModel: String {
        case REVIEW_PROMPT_SHOWN
        case REVIEW_REQUEST_TRIGGERED
    }
}
