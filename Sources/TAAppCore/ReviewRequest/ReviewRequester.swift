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

    public typealias EligibilityProvider = @MainActor (ReviewRequestStore) -> Bool

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
    private let eligibilityProvider: EligibilityProvider
    private let strategyDescription: String
    public var analytics: TAAnalytics?
    @Published public private(set) var state: State

    /// Inject a custom store for tests or AppGroup setups.
    /// The requester is intended to be owned by app infrastructure such as a delegate,
    /// lifecycle handler, or dependency container rather than a SwiftUI `@StateObject`.
    public init(
        store: ReviewRequestStore = .standard,
        strategy: ReviewRequestStrategy = AnyReviewRequestStrategy.after(days: 120, launches: 15, events: 5),
        analytics: TAAnalytics? = nil
    ) {
        self.store = store
        self.eligibilityProvider = { strategy.shouldRequestReview(using: $0) }
        self.strategyDescription = String(describing: strategy)
        self.analytics = analytics
        self.state = Self.makeState(store: store, eligibilityProvider: eligibilityProvider)
    }

    /// Inject a dynamic eligibility provider for cases where review thresholds come from
    /// remote config or other main-actor owned services.
    public init(
        store: ReviewRequestStore = .standard,
        strategyDescription: String = "dynamic_provider",
        analytics: TAAnalytics? = nil,
        eligibilityProvider: @escaping EligibilityProvider
    ) {
        self.store = store
        self.eligibilityProvider = eligibilityProvider
        self.strategyDescription = strategyDescription
        self.analytics = analytics
        self.state = Self.makeState(store: store, eligibilityProvider: eligibilityProvider)
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

    /// Records a positive event and immediately evaluates the current eligibility.
    @discardableResult
    public func recordPositiveEventAndRequestIfAppropriate() -> Bool {
        // `requestIfAppropriate()` refreshes state itself, so record the event on the
        // store directly to avoid recomputing state twice in a row.
        store.recordEvent()
        return requestIfAppropriate()
    }

    /// Attempts to display a prompt if the given strategy evaluates to `true`.
    @discardableResult
    public func requestIfAppropriate() -> Bool {
        refreshState()
        guard state.isEligibleForRequest else { return false }

        analytics?.track(event: .init(EventAnalyticsModel.REVIEW_REQUEST_TRIGGERED.rawValue), params: [
            "strategy_type": strategyDescription
        ])

        // Only consume eligibility (analytics, counter reset, cooldown) if we could
        // actually hand the request to the system. Without a foreground-active scene
        // the system prompt can't be presented, so the eligible window must be preserved.
        guard performSystemRequest() else { return false }

        analytics?.track(event: .init(EventAnalyticsModel.REVIEW_PROMPT_SHOWN.rawValue), params: [
            "strategy_type": strategyDescription
        ])
        store.recordPromptShown()
        refreshState()
        return true
    }

    public func reload() {
        refreshState()
    }

    // MARK: System interaction
    /// - Returns: `true` if the request was handed to the system, `false` if there was
    ///   no foreground-active scene to present it in. A `true` result only means the
    ///   request was made — the system may still choose not to display it (annual quota).
    private func performSystemRequest() -> Bool {
        guard let scene = UIApplication.shared.connectedScenes
                .first(where: { ($0 as? UIWindowScene)?.activationState == .foregroundActive }) as? UIWindowScene else { return false }
        AppStore.requestReview(in: scene)
        return true
    }

    private func refreshState() {
        let updatedState = Self.makeState(store: store, eligibilityProvider: eligibilityProvider)
        guard state != updatedState else { return }
        state = updatedState
    }

    private static func makeState(
        store: ReviewRequestStore,
        eligibilityProvider: EligibilityProvider
    ) -> State {
        State(
            lastPromptDate: store.lastPromptDate,
            launchesSincePrompt: store.launchesSincePrompt,
            eventsSincePrompt: store.eventsSincePrompt,
            isEligibleForRequest: eligibilityProvider(store)
        )
    }
}


extension ReviewRequester {
    
    enum EventAnalyticsModel: String {
        case REVIEW_PROMPT_SHOWN
        case REVIEW_REQUEST_TRIGGERED
    }
}
