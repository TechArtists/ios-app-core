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
    
    private let isCompleted: Binding<Bool>?
    private let stepsBuilder: () -> Journey.StepsArrayWrapper

    public var body: some View {
        Journey(isCompleted: isCompleted, stepsBuilder)
            .onAppear {
                analytics.trackOnboardingEnter(extraParams: nil)
            }
            .onChange(of: isCompleted?.wrappedValue) { newValue in
                if newValue == true {
                    analytics.trackOnboardingExit(extraParams: nil)
                }
            }
    }

    public init(isCompleted: Binding<Bool>? = nil, @Journey.JourneyBuilder content: @escaping () -> Journey.StepsArrayWrapper) {
        self.isCompleted = isCompleted
        self.stepsBuilder = content
    }
}
