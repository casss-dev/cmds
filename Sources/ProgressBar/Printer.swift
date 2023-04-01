//
//  Printer.swift
//  
//
//  Created by casss-dev in 2023
//

import Foundation
import ANSITerminal

/// A renderer for progress which prints a percentage (between 0-1)
public protocol ProgressRenderer {
    /// A block to execute before rendering
    mutating func begin()
    /// Renders the progress
    /// - Parameter percent: A percentage between 0 and 1
    func print(percent: Double, message: String?)
    /// A block to execute after rendering
    mutating func finish()
}

public struct ProgressPrinter: ProgressRenderer {

    public typealias Grid = (row: Int, col: Int)

    public var size: Grid = readScreenSize()
    public var start: Grid = readCursorPos()

    public var styles: Style

    public init(styles: Style = .default) {
        self.styles = styles
    }

    private func calculatedBar(using percent: Double) -> String {
        let leading = styles.barLeading(percent, size.row)
        let trailing = styles.barTrailing(percent, size.row - leading.count)
        let barMaxWidth = size.row - leading.count - trailing.count
        let bar = styles.barMid(percent, barMaxWidth)
        return leading + bar + trailing
    }

    public mutating func begin() {
        size = readScreenSize()
        start = readCursorPos()
        cursorOff()
    }

    public func print(percent: Double, message: String? = nil) {
        clearLine()
        render(calculatedBar(using: percent), at: start)
        if let message { render(message, at: (row: start.row + 1, col: start.col)) }
        clearToEndOfLine()
        clearBelow()
    }

    public mutating func finish() {
        moveLineDown()
        cursorOn()
    }

    private func render(_ msg: String, at pos: Grid) {
        moveTo(pos.row, pos.col)
        write(msg)
    }
}

public extension ProgressPrinter {

    /// The style of the progress printer
    struct Style {

        /// A closure which passes the percent and available width of the bar,
        /// returning a `String` which should render a portion of the progress bar.
        public typealias RenderBar = (_ percent: Double, _ screenWidth: Int) -> String

        /// The progress bar's default styling
        ///
        /// ```
        /// // Example Output:
        /// // [=====     ] 50.00%
        /// ```
        public static let `default` = Style(
            barTrailing: { percent, _ in
                "] \(String(format: "%.2f", percent * 100))%"
            }
        )

        /// The `String` before the bar (default: "[")
        public var barLeading: RenderBar

        /// The `String` representing the mutable portion of the bar.
        /// The returned `String` should include the bar's empty space
        public var barMid: RenderBar

        /// The `String` after the bar (default: "]")
        public var barTrailing: RenderBar

        public init(
            barLeading: @escaping RenderBar = { (_, _) in "[" },
            barMid: @escaping RenderBar = { percent, width in
                let barFill = Int(round(percent * Double(width)))
                let bar = Array(repeating: "=", count: barFill)
                    .joined(separator: "")
                let emptySpace = Array(repeating: " ", count: width - barFill)
                    .joined(separator: "")
                return bar + emptySpace
            },
            barTrailing: @escaping RenderBar = { (_, _) in "]" }
        ) {
            self.barLeading = barLeading
            self.barMid = barMid
            self.barTrailing = barTrailing
        }
    }

}
