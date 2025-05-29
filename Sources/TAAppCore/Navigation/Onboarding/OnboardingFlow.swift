/*
MIT License

Copyright (c) 2025 Tech Artists Agency

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

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
        .onChange(of: predefinedFlowSteps.elements) { newElements in
            navigationPathManager.updateViews(with: newElements)
        }
        .onDisappear {
            analytics.trackOnboardingExit(extraParams: nil)
        }
        .environmentObject(navigationPathManager)
    }
    
    public init(isCompleted: Binding<Bool>? = nil, @OnboardingFlowBuilder _ content: () -> StepsArrayWrapper) {
        self.isCompleted = isCompleted
        let predefinedFlowSteps = content()
        self.predefinedFlowSteps = predefinedFlowSteps
        self._navigationPathManager = StateObject(wrappedValue: NavigationPathManager(isCompleted: isCompleted, predefinedFlowSteps: predefinedFlowSteps))
    }
}
