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

    private let store: ReviewRequestStore
    private let strategy: ReviewRequestStrategy
    public var analytics: TAAnalytics?

    /// Inject a custom store for tests or AppGroup setups.
    public init(
        store: ReviewRequestStore = .standard,
        strategy: ReviewRequestStrategy = AnyReviewRequestStrategy.after(days: 120, launches: 15, events: 5),
        analytics: TAAnalytics? = nil
    ) {
        self.store = store
        self.strategy = strategy
        self.analytics = analytics
    }

    // MARK: Public API
    /// Records a launch & attempts to show the prompt if the `strategy` permits.
    /// – Call early in `scene(_:willConnectTo:options:)` or `applicationDidFinishLaunching`.
    public func applicationDidLaunch() {
        store.recordLaunch()
    }

    /// Manually record a positive in‑app event (level clear, workout finished, etc.).
    public func recordPositiveEvent() {
        store.recordEvent()
    }

    /// Attempts to display a prompt if the given strategy evaluates to `true`.
    public func requestIfAppropriate() {
        guard strategy.shouldRequestReview(using: store) else { return }
        
        analytics?.track(event: .init(EventAnalyticsModel.REVIEW_REQUEST_TRIGGERED.rawValue), params: [
            "strategy_type": String(describing: strategy)
        ])
        performSystemRequest()
        analytics?.track(event: .init(EventAnalyticsModel.REVIEW_PROMPT_SHOWN.rawValue), params: [
            "strategy_type": String(describing: strategy)
        ])
        store.recordPromptShown()
    }

    // MARK: System interaction
    private func performSystemRequest() {
        guard let scene = UIApplication.shared.connectedScenes
                .first(where: { ($0 as? UIWindowScene)?.activationState == .foregroundActive }) as? UIWindowScene else { return }
        SKStoreReviewController.requestReview(in: scene)
    }
}


extension ReviewRequester {
    
    enum EventAnalyticsModel: String {
        case REVIEW_PROMPT_SHOWN
        case REVIEW_REQUEST_TRIGGERED
    }
}
