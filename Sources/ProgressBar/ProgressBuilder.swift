//
//  ProgressBuilder.swift
//  
//
//  Created by casss-dev in 2023
//

import Foundation

@resultBuilder public struct ProgressBuilder{

    public typealias Element = any Talliable

    /// (Occurs last after array is built)
    public static func buildBlock(_ components: [Element]...) -> [Element] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: Element) -> [Element] {
        [expression]
    }

    public static func buildArray(_ components: [[Element]]) -> [Element] {
        components.flatMap { $0 }
    }

    public static func buildOptional(_ component: [Element]?) -> [Element] {
        component ?? []
    }

    public static func buildEither(first component: [Element]) -> [Element] {
        component
    }

    public static func buildEither(second component: [Element]) -> [Element] {
        component
    }

    public static func buildLimitedAvailability(_ component: [Element]) -> [Element] {
        component
    }
}

