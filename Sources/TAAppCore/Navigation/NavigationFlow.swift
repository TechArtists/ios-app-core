//
//  NavigationFlow.swift
//  TAAppCore
//
//  Created by Robert Tataru on 27.05.2025.
//

import SwiftUI

public struct NavigationFlow: View {
    
    @StateObject var navigationPathManager: NavigationPathManager<NavigationFlow.StepsArrayWrapper>
    
    private let predefinedFlowSteps: StepsArrayWrapper
    private let isCompleted: Binding<Bool>?
    
    public var body: some View {
        NavigationStack(path: $navigationPathManager.path) {
            navigationPathManager
                .firstStepFlowView
                .navigationDestination(for: NavigationStepIdentifier.self) { stepIdentifier in
                    navigationPathManager.view(for: stepIdentifier)
                }
        }
        .environmentObject(navigationPathManager)
        .onChange(of: predefinedFlowSteps.elements) { newElements in
            navigationPathManager.updateViews(with: newElements)
        }
    }
    
    public init(isCompleted: Binding<Bool>? = nil, @NavigationFlowBuilder _ content: () -> StepsArrayWrapper) {
        self.isCompleted = isCompleted
        let predefinedFlowSteps = content()
        self.predefinedFlowSteps = predefinedFlowSteps
        self._navigationPathManager = StateObject(wrappedValue: NavigationPathManager(isCompleted: isCompleted, predefinedFlowSteps: predefinedFlowSteps))
    }
}
