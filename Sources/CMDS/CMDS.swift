//
//  CMDS.swift
//  
//
//  Created by casss-dev in 2023
//

import Foundation
import Internals
import ANSITerminal

public struct CMDS {

    /// A queue of options. Result builders don't let you pass arguments in,
    /// so a global queue is necessary to keep track of scoped configurations.
    public static var optionsQueue: [Options] = []

    /// Global configuration for every shell command
    public static var shellConfig = ShellConfig()

    public var style: Style

    /// The result of all commands within the execution block
    public var result: ShellResult

    public init(
        options: Options = .default,
        style: Style = Style(),
        @CommandBuilder execute: () throws -> ShellResult
    ) {
        Self.optionsQueue.insert(options, at: 0)
        self.style = style
        do {
            result = try execute()
        } catch {
            result = .failure(.init(status: .min, message: error.localizedDescription))
        }
    }

    /// Returns the result of stdout stylized
    public var stdout: String { style.stdOutStyle((try? result.get()) ?? "") }

    /// Returns the result of stderr stylized
    public var stderr: String {
        var out = ""
        if case .failure(let error) = result {
            out = error.message
        }
        return style.stdErrorStyle(out)
    }

    /// Returns stylized output
    public var output: String {
        switch result {
            case .success:
                return stdout
            case .failure:
                return stdout
        }
    }

    /// Returns the result of the execution block
    @discardableResult
    public func callAsFunction() -> ShellResult { result }

    /// Prints the result with the set style
    public func print() {
        switch callAsFunction() {
        case .success(let output):
            Swift.print(style.stdOutStyle(output))
        case .failure(let error):
            Swift.print(style.stdErrorStyle(error.message), to: &STDErrorOut.default)
        }
    }
}

public extension CMDS {

    typealias Options = Process.ExecuteOptions

    /// A base configuration for shell processes
    struct ShellConfig {
        public var executableURL: URL = URL(fileURLWithPath: "/usr/bin/env")
        public var initialArguments: [String] = ["bash", "-c"]
    }

    /// A style for terminal output
    struct Style {

        /// A closure which consumes the `text`, stylizes it, and returns the stylized result
        public typealias Stylize = (_ text: String) -> String

        /// The standard output style
        public var stdOutStyle: Stylize

        /// The standard error style
        public var stdErrorStyle: Stylize

        public init(
            stdOutStyle: @escaping Stylize = { $0 },
            stdErrorStyle: @escaping Stylize = { $0.red }
        ) {
            self.stdOutStyle = stdOutStyle
            self.stdErrorStyle = stdErrorStyle
        }
    }
}
