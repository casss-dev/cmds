//
//  ProgressBar.swift
//  
//
//  Created by casss-dev in 2023
//

import Foundation

/**
 A progress bar for display in the terminal. It features support for
 custom styling and printing. Progress is calculated automatically when
 synchronous statements are passed into the `statements` closure.

 Progress calculations are made possible by prefixing statements with a `*` operator,
 which wraps the statement in a closure so it can be tallied before execution.

 ```
 ProgressBar {
    *sleep(2)
    // progress = 25%

    *sleep(1)
    // progress = 50%

    *sleep(3)
    // progress = 75%

    *sleep(5)
    // progress = 100%
 }
 ```
 */
public struct ProgressBar {

    public typealias Statement = any Talliable

    public let statements: [Statement]

    public var progress: Double = 0
    public let total: Double

    public private(set) var printer: ProgressRenderer

    public init(
        printer: ProgressRenderer = ProgressPrinter(),
        @ProgressBuilder _ statements: () -> [Statement]
    ) {
        self.printer = printer
        self.statements = statements()
        self.total = Double(self.statements.count)
    }

    @discardableResult public func callAsFunction() -> Self {
        var mutated = self
        mutated.execute()
        return mutated
    }

    private mutating func execute() {
        printer.begin()
        for statement in statements {
            printer.print(
                percent: progress / total,
                message: statement.message
            )
            _ = statement.closure()
            progress += 1
            printer.print(
                percent: progress / total,
                message: statement.message
            )
        }
        printer.finish()
    }
}
