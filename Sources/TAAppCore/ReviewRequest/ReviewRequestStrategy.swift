//
//  ReviewRequestStrategy.swift
//  TAAppCore
//
//  Created by Robert Tataru on 22.04.2025.
//

import Foundation

public protocol ReviewRequestStrategy {
    
    func shouldRequestReview(using store: ReviewRequestStore) -> Bool
}

public struct AnyReviewRequestStrategy: ReviewRequestStrategy {
    
    private let checker: (ReviewRequestStore) -> Bool
    
    public init(_ checker: @escaping (ReviewRequestStore) -> Bool) {
        self.checker = checker
    }
    public func shouldRequestReview(using store: ReviewRequestStore) -> Bool {
        checker(store)
    }
}

public extension ReviewRequestStrategy {
    
    static var always: ReviewRequestStrategy { AnyReviewRequestStrategy { _ in true } }
    static var never: ReviewRequestStrategy  { AnyReviewRequestStrategy { _ in false } }

    static func after(days: Int = 0, launches: Int = 0, events: Int = 0) -> ReviewRequestStrategy {
        AnyReviewRequestStrategy { store in
            let dayOK: Bool = {
                guard days > 0, let last = store.lastPromptDate else { return true }
                return Calendar.current.dateComponents([.day], from: last, to: .init()).day ?? 0 >= days
            }()
            let launchOK = launches == 0 || store.launchesSincePrompt >= launches
            let eventOK  = events  == 0 || store.eventsSincePrompt  >= events
            return dayOK && launchOK && eventOK
        }
    }

    static func all(_ strategies: [ReviewRequestStrategy]) -> ReviewRequestStrategy {
        AnyReviewRequestStrategy { store in
            strategies.allSatisfy { $0.shouldRequestReview(using: store) }
        }
    }
}
