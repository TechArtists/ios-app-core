//
//  OnboardingFlow.swift
//  TAAppCore
//
//  Created by Robert Tataru on 29.05.2025.
//

import SwiftUI
import TAAnalytics

public struct OnboardingFlow: View {
    
    @EnvironmentObject var analytics: TAAnalytics
    
    @StateObject var navigationPathManager: NavigationPathManager<OnboardingFlow.StepsArrayWrapper>
    
    private let predefinedFlowSteps: StepsArrayWrapper
    private let isCompleted: Binding<Bool>?
    
    public var body: some View {
        NavigationStack(path: $navigationPathManager.path) {
            navigationPathManager
                .firstStepFlowView
                .navigationDestination(for: NavigationStepIdentifier.self) { stepIdentifier in
                    navigationPathManager.view(for: stepIdentifier)
                }
                .onAppear {
                    analytics.trackOnboardingEnter(extraParams: nil)
                }
        }
        .environmentObject(navigationPathManager)
        .onChange(of: predefinedFlowSteps.elements) { newElements in
            navigationPathManager.updateViews(with: newElements)
        }
        .onDisappear {
            analytics.trackOnboardingExit(extraParams: nil)
        }
    }
    
    public init(isCompleted: Binding<Bool>? = nil, @OnboardingFlowBuilder _ content: () -> StepsArrayWrapper) {
        self.isCompleted = isCompleted
        let predefinedFlowSteps = content()
        self.predefinedFlowSteps = predefinedFlowSteps
        self._navigationPathManager = StateObject(wrappedValue: NavigationPathManager(isCompleted: isCompleted, predefinedFlowSteps: predefinedFlowSteps))
    }
}
