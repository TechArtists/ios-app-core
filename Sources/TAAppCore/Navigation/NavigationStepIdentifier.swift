//
//  NavigationStepIdentifier.swift
//  TAAppCore
//
//  Created by Robert Tataru on 26.05.2025.
//

import SwiftUI

/// Identifies a single step in a `ManagedNavigationStack`.
/// Can represent either a static (declaratively defined) or custom (programmatically pushed) step.
struct NavigationStepIdentifier {
    /// Defines how this step should be uniquely identified.
    enum Kind: Equatable {
        /// Identifier is derived from the View's type and source location (for static steps).
        case viewTypeAndSourceLocation

        /// Identifier is derived from a user-defined `Hashable` value, usually from `Identifiable` conformance.
        case identifiable(any Hashable)

        static func == (lhs: Kind, rhs: Kind) -> Bool {
            switch (lhs, rhs) {
            case (.viewTypeAndSourceLocation, .viewTypeAndSourceLocation):
                return true
            case let (.identifiable(l), .identifiable(r)):
                return l.equals(r)
            default:
                return false
            }
        }
    }

    /// The identifier kind, either by view type + location, or via `.id`.
    let kind: Kind

    /// The full type of the view, including modifiers.
    let viewType: any View.Type

    /// The source location if this was declared in a static stack.
    let sourceMetadata: (fileID: StaticString, line: UInt, column: UInt)?

    /// True if this view was pushed at runtime (not declared in the result builder).
    var isCustom: Bool { sourceMetadata == nil }

    /// Main initializer for navigation step identification.
    @MainActor
    init(element: any NavigationStepIdentifiableView) {
        self.viewType = type(of: element.view)
        self.sourceMetadata = element.sourceMetadata

        // Prefer NavigationStepIdentifiable first
        if let stepIdentifiable = element.view as? any NavigationStepIdentifiable {
            self.kind = .identifiable(stepIdentifiable.id)
        } else if let identifiable = element.view as? any Identifiable {
            self.kind = .identifiable(identifiable.id)
        } else {
            self.kind = .viewTypeAndSourceLocation
        }
    }
}

// MARK: - Hashable

extension NavigationStepIdentifier: Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.kind == rhs.kind, lhs.viewType == rhs.viewType else {
            return false
        }

        switch (lhs.sourceMetadata, rhs.sourceMetadata) {
        case let ((lFile, lLine, lCol)?, (rFile, rLine, rCol)?):
            return lFile.description == rFile.description && lLine == rLine && lCol == rCol
        case (nil, nil):
            return true
        default:
            return false
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(viewType))

        switch kind {
        case .viewTypeAndSourceLocation:
            if let sourceMetadata {
                hasher.combine(sourceMetadata.fileID.description)
                hasher.combine(sourceMetadata.line)
                hasher.combine(sourceMetadata.column)
            }
        case .identifiable(let value):
            hasher.combine(ObjectIdentifier(type(of: value)))
            hasher.combine(value)
        }
    }
}



// MARK: - Hashable runtime equality helper

private extension Hashable {
    func equals(_ other: any Hashable) -> Bool {
        if let other = other as? Self {
            return self == other
        }
        return false
    }
}
