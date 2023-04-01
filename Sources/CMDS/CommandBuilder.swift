//
//  CommandBuilder.swift
//
//
//  Created by casss-dev in 2023
//

import Foundation

@resultBuilder
public struct CommandBuilder {

    public static func buildBlock(_ components: [AnyProcess]...) -> [AnyProcess] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: AnyProcess) -> [AnyProcess] {
        [expression]
    }

    public static func buildExpression(_ expression: ()) -> [AnyProcess] {
        []
    }

    public static func buildExpression(_ expression: [AnyProcess]) -> [AnyProcess] {
        expression
    }

    public static func buildOptional(_ component: [AnyProcess]?) -> [AnyProcess] {
        component ?? []
    }

    public static func buildArray(_ components: [[AnyProcess]]) -> [AnyProcess] {
        components.flatMap { $0 }
    }

    public static func buildEither(first component: [AnyProcess]) -> [AnyProcess] {
        component
    }

    public static func buildEither(second component: [AnyProcess]) -> [AnyProcess] {
        component
    }

    public static func buildFinalResult(_ component: [AnyProcess]) -> [AnyProcess] {
        component
    }

    public static func buildFinalResult(_ component: [AnyProcess]) -> ShellResult {
        let options = CMDS.optionsQueue.removeFirst()
        return component.executeAll(with: options)
    }
}
