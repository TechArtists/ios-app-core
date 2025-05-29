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
//  NavigationPathManager.swift
//  TAAppCore
//
//  Created by Robert Tataru on 27.05.2025.
//

import SwiftUI
import Collections

@MainActor
public class NavigationPathManager<Container: NavigationStepContainer>: ObservableObject {
    
    public typealias StepElement = Container.Step
    
    /// The navigation path of step identifiers, including both predefined and custom steps.
    /// Observing changes here cleans up removed custom steps and reapplies any pending removals.
    @Published var path: [NavigationStepIdentifier] = [] {
        didSet {
            guard oldValue != path else { return }

            for step in oldValue where step.isCustom && !path.contains(step) {
                customSteps.removeValue(forKey: step)
            }
            reapplyPendingRemovalsIfNeeded()
        }
    }

    /// Internal state for completed binding, predefined steps, custom steps, and deferred removals.
    
    private var isCompleted: Binding<Bool>?
    private var predefinedFlowSteps: OrderedDictionary<NavigationStepIdentifier, any View> = [:]
    private var customSteps: [NavigationStepIdentifier: any View] = [:]
    private var pendingRemovals: Set<NavigationStepIdentifier> = []
    
    // MARK: - Initialization

    /// Initializes the navigation manager with an optional completion binding and a set of predefined flow steps.
    public init(isCompleted: Binding<Bool>? = nil, predefinedFlowSteps: Container) {
        configure(isCompleted: isCompleted, predefinedFlowSteps: predefinedFlowSteps)
    }

    // MARK: - Configuration

    /// Configures the manager with the given completion binding and container of predefined steps.
    private func configure(isCompleted: Binding<Bool>?, predefinedFlowSteps: Container) {
        self.isCompleted = isCompleted
        updateViews(with: predefinedFlowSteps.elements)
    }

    /// Updates the set of views based on a new list of step elements, managing conflicts and removals.
    public func updateViews(with elements: [StepElement]) {
        func failWithConflictingIdentifiers(
            existingIdentifier: NavigationStepIdentifier,
            newIdentifier: NavigationStepIdentifier,
            file: StaticString = #file,
            line: UInt = #line
        ) -> Never {
            preconditionFailure(
                """
                NavigationPathManager: Duplicate step identifiers detected.
                Use 'navigationStepIdentifier(_:)' to make each step unique.
                Problematic identifier: \(newIdentifier).
                Conflicting identifier: \(existingIdentifier)
                """,
                file: file,
                line: line
            )
        }

        let currentStepIndex = currentStep.flatMap {
            predefinedFlowSteps.elements.keys.firstIndex(of: $0)
        } ?? 0

        let existingKeys = Array(predefinedFlowSteps.elements.keys)
        let newIdentifiers = elements.map { NavigationStepIdentifier(element: $0) }

        for (index, key) in existingKeys.enumerated() {
            if index > currentStepIndex {
                predefinedFlowSteps.removeValue(forKey: key)
            } else {
                if !newIdentifiers.contains(key) {
                    pendingRemovals.insert(key)
                }
            }
        }

        for element in elements {
            let identifier = NavigationStepIdentifier(element: element)
            if let existingIndex = predefinedFlowSteps.elements.keys.firstIndex(of: identifier) {
                if existingIndex > currentStepIndex {
                    failWithConflictingIdentifiers(
                        existingIdentifier: predefinedFlowSteps.elements.keys[existingIndex],
                        newIdentifier: identifier
                    )
                } else {
                    continue
                }
            }
            predefinedFlowSteps[identifier] = element.view
        }

        reapplyPendingRemovalsIfNeeded()
        updateIsCompleteBinding()
    }

    // MARK: - Private Helpers

    /// Sets the completion binding to true when there are no predefined steps left.
    private func updateIsCompleteBinding() {
        if predefinedFlowSteps.isEmpty && !(isCompleted?.wrappedValue ?? false) {
            isCompleted?.wrappedValue = true
        }
    }

    /// Removes any steps that were deferred until after the current position in the flow.
    private func reapplyPendingRemovalsIfNeeded() {
        guard let currentIndex = currentStep.flatMap({
            predefinedFlowSteps.elements.keys.firstIndex(of: $0)
        }) else { return }

        for id in pendingRemovals {
            if let index = predefinedFlowSteps.elements.keys.firstIndex(of: id),
               index > currentIndex {
                predefinedFlowSteps.removeValue(forKey: id)
                pendingRemovals.remove(id)
            }
        }
    }

    // MARK: - Navigation Control

    /// Advances to the next step in the predefined flow, or marks completion if at the end.
    public func nextStep() {
        guard let currentStepIndex = predefinedFlowSteps.elements.keys.firstIndex(where: { $0 == currentStep }),
              currentStepIndex + 1 < predefinedFlowSteps.elements.count else {
            isCompleted?.wrappedValue = true
            return
        }
        path.append(predefinedFlowSteps.elements.keys[currentStepIndex + 1])
    }
    
    public var currentStepInThePath: Int {
        path.count
    }

    /// Returns the view for the first step in the predefined flow, or an empty view if none.
    var firstStepFlowView: AnyView {
        guard let firstStepFlowIdentifier, let view = predefinedFlowSteps[firstStepFlowIdentifier] else {
            return AnyView(EmptyView())
        }
        return AnyView(view)
    }

    /// The currently active non-custom step identifier, or the first step if none selected.
    private var currentStep: NavigationStepIdentifier? {
        guard let lastElement = path.last(where: { !$0.isCustom }) else {
            return firstStepFlowIdentifier
        }
        return lastElement
    }

    /// The identifier for the first step in the predefined flow, if available.
    private var firstStepFlowIdentifier: NavigationStepIdentifier? {
        predefinedFlowSteps.elements.first?.key
    }

    /// Returns the view associated with the given step identifier, handling custom and predefined steps.
    func view(for stepIdentifier: NavigationStepIdentifier) -> AnyView {
        let view = stepIdentifier.isCustom
        ? customSteps[stepIdentifier]
        : predefinedFlowSteps[stepIdentifier]
        
        if let view {
            return AnyView(view)
        } else {
            return AnyView(EmptyView())
        }
    }
}
