//
//  ReviewRequestStore.swift
//  TAAppCore
//
//  Created by Robert Tataru on 22.04.2025.
//

import Foundation

public final class ReviewRequestStore {
    public static let standard = ReviewRequestStore()

    private let defaults: UserDefaults
    private let prefix = "reviewRequester."

    // MARK: Keys
    private enum Key: String {
        case promptDate = "lastPromptDate"
        case launchCount = "launchesSincePrompt"
        case eventCount  = "eventsSincePrompt"
    }

    // MARK: Init
    /// - parameter suiteName: Optional for App‑Group use; nil → `.standard`.
    public init(suiteName: String? = nil) {
        defaults = UserDefaults(suiteName: suiteName) ?? .standard
    }

    // MARK: State accessors
    public var lastPromptDate: Date? {
        get { defaults.object(forKey: prefix+Key.promptDate.rawValue) as? Date }
        set { defaults.set(newValue, forKey: prefix+Key.promptDate.rawValue) }
    }

    public var launchesSincePrompt: Int {
        get { defaults.integer(forKey: prefix+Key.launchCount.rawValue) }
        set { defaults.set(newValue, forKey: prefix+Key.launchCount.rawValue) }
    }

    public var eventsSincePrompt: Int {
        get { defaults.integer(forKey: prefix+Key.eventCount.rawValue) }
        set { defaults.set(newValue, forKey: prefix+Key.eventCount.rawValue) }
    }

    // MARK: Mutations
    public func recordLaunch() { launchesSincePrompt += 1 }
    public func recordEvent()  { eventsSincePrompt  += 1 }

    public func recordPromptShown() {
        lastPromptDate = Date()
        launchesSincePrompt = 0
        eventsSincePrompt  = 0
    }
}
