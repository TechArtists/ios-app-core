//
//  OnboardingJourney.swift
//  TAAppCore
//
//  Created by Robert Tataru on 30.05.2025.
//

import SwiftUI
import TAAnalytics

public struct OnboardingJourney: View {
    
    @EnvironmentObject private var analytics: TAAnalytics
    @State private var didTrackOnboardingExit = false
    
    private let isCompleted: Binding<Bool>?
    private let stepsBuilder: () -> Journey.StepsArrayWrapper
    
    public var body: some View {
        Journey(isCompleted: isCompleted, stepsBuilder)
            .onAppear {
                didTrackOnboardingExit = false
                analytics.trackOnboardingEnter(extraParams: nil)
            }
            .onDisappear {
                trackOnboardingExitOnce()
            }
            .onChange(of: isCompleted?.wrappedValue) { newValue in
                if newValue == true {
                    trackOnboardingExitOnce()
                }
            }
    }
    
    public init( isCompleted: Binding<Bool>? = nil, @Journey.JourneyBuilder content: @escaping () -> Journey.StepsArrayWrapper) {
        self.isCompleted = isCompleted
        self.stepsBuilder = content
    }
    
    public init( isCompleted: Binding<Bool>? = nil, stepsWrapped: @escaping () -> Journey.StepsArrayWrapper) {
        self.isCompleted = isCompleted
        self.stepsBuilder = { stepsWrapped() }
    }

    private func trackOnboardingExitOnce() {
        guard !didTrackOnboardingExit else { return }
        didTrackOnboardingExit = true
        analytics.trackOnboardingExit(extraParams: nil)
    }
}
