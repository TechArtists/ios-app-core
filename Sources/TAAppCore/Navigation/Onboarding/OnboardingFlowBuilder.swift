//
//  OnboardingFlowBuilder.swift
//  TAAppCore
//
//  Created by Robert Tataru on 29.05.2025.
//

import SwiftUI
import TAAnalytics

public typealias OnboardingPathManager = NavigationPathManager<OnboardingFlow.StepsArrayWrapper>

public protocol TAOnboardingView: TAAnalyticsView {
    
    var navigationPathManager: NavigationPathManager<OnboardingFlow.StepsArrayWrapper> { get }
}

extension OnboardingFlow {
    
    public struct StepsArrayWrapper: NavigationStepContainer {
        
        public struct Element: NavigationStepIdentifiableView {
            public var onboardingView: any TAOnboardingView
            public var sourceMetadata: (fileID: StaticString, line: UInt, column: UInt)
            
            public var view: any View {
                onboardingView
            }
        }
        
        public let elements: [Element]
        
        init(elements: [Element]) {
            self.elements = elements
        }
    }
    
    @resultBuilder
    public enum OnboardingFlowBuilder {
        /// Navigation Flow Element
        public typealias Element = StepsArrayWrapper.Element
        
        /// If declared, provides contextual type information for statement expressions to translate them into partial results.
        public static func buildExpression(
            _ view: any TAOnboardingView,
            _ fileId: StaticString = #fileID,
            _ line: UInt = #line,
            _ column: UInt = #column
        ) -> [Element] {
            [Element(onboardingView: view, sourceMetadata: (fileId, line, column))]
        }
        
        /// Required by every result builder to build combined results from statement blocks.
        public static func buildBlock(_ children: [Element]...) -> [Element] {
            children.flatMap { $0 }
        }
        
        /// Enables support for `if` statements that do not have an `else`.
        public static func buildOptional(_ elements: [Element]?) -> [Element] {
            // swiftlint:disable:previous discouraged_optional_collection
            // The optional collection is a requirement defined by @resultBuilder, we can not use a non-optional collection here.
            elements ?? []
        }
        
        /// With buildEither(second:), enables support for 'if-else' and 'switch' statements by folding conditional results into a single result.
        public static func buildEither(first: [Element]) -> [Element] {
            first
        }
        
        /// With buildEither(first:), enables support for 'if-else' and 'switch' statements by folding conditional results into a single result.
        public static func buildEither(second: [Element]) -> [Element] {
            second
        }
        
        /// If declared, this will be called on the partial result of an 'if #available' block to allow the result builder to erase type information.
        public static func buildLimitedAvailability(_ elements: [Element]) -> [Element] {
            elements
        }
        
        /// `for` loop support.
        public static func buildArray(_ components: [[Element]]) -> [Element] {
            fatalError("Unavailable")
        }
        
        /// If declared, this will be called on the partial result from the outermost block statement to produce the final returned result.
        public static func buildFinalResult(_ elements: [Element]) -> StepsArrayWrapper {
            StepsArrayWrapper(elements: elements)
        }
    }
}

extension OnboardingFlow.StepsArrayWrapper.Element: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.sourceMetadata.fileID.description == rhs.sourceMetadata.fileID.description &&
        lhs.sourceMetadata.line == rhs.sourceMetadata.line &&
        lhs.sourceMetadata.column == rhs.sourceMetadata.column
    }
}

extension OnboardingFlow.StepsArrayWrapper: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.elements == rhs.elements
    }
}
