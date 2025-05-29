//
//  NavigationStepIdentifiable.swift
//  TAAppCore
//
//  Created by Robert Tataru on 27.05.2025.
//

import SwiftUI

/// Protocol for views that want to explicitly provide a unique identity
/// for navigation tracking purposes.
@MainActor
public protocol NavigationStepIdentifiable {
    associatedtype ID: Hashable
    var id: ID { get }
}

struct NavigationStepIdentifierModifier<ID: Hashable>: ViewModifier, NavigationStepIdentifiable {
    let id: ID

    func body(content: Content) -> some View {
        content
    }
}

extension View {
    /// Applies a custom navigation step identifier to the view.
    public func navigationStepIdentifier<ID: Hashable>(_ id: ID) -> some View {
        self.modifier(NavigationStepIdentifierModifier(id: id))
    }
}

extension ModifiedContent: NavigationStepIdentifiable where Modifier: NavigationStepIdentifiable {
    public var id: Modifier.ID {
        modifier.id
    }
}
