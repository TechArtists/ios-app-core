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
