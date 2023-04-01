//
//  Process.swift
//
//
//  Created by casss-dev in 2023
//

import Foundation

/// A type-erased process with guaranteed properties and methods
@dynamicMemberLookup
public protocol AnyProcess {

    /// The underlying process
    var process: Process { get }

    /// Executes the underlying process
    /// - Parameter options: Additional options to control execution
    /// - Returns: A `ShellResult` with a failure or success
    func execute(with options: Process.ExecuteOptions) -> ShellResult

    /// Pipes the underlying process to another process
    /// - Parameter wrapped: The input process to pipe this process's standard out into
    /// - Returns: A `PipedProcess` which references itself and the parent, creating a singly linked list
    func piped(to wrapped: AnyProcess) -> PipedProcess

    subscript<T>(dynamicMember keyPath: KeyPath<Process, T>) -> T { get }
    subscript<T>(dynamicMember keyPath: ReferenceWritableKeyPath<Process, T>, value: T) -> T { get set }
}

public extension AnyProcess {

    func execute(with options: Process.ExecuteOptions = .default) -> ShellResult {
        process.execute(with: options)
    }

    func piped(to wrapped: AnyProcess) -> PipedProcess {
        self.process.piped(to: wrapped.process)
    }

    subscript<T>(dynamicMember keyPath: KeyPath<Process, T>) -> T {
        process[keyPath: keyPath]
    }

    subscript<T>(dynamicMember keyPath: ReferenceWritableKeyPath<Process, T>, value: T) -> T {
        get { process[keyPath: keyPath] }
        set { process[keyPath: keyPath] = value }
    }
}

extension String: AnyProcess {

    public var process: Process {
        if isEmpty { return sh("echo") }
        return sh(self)
    }
}

public class PipedProcess: AnyProcess {

    public var process: Process

    public var parent: PipedProcess?

    public init(_ process: Process, parent: PipedProcess? = nil) {
        self.process = process
        self.parent = parent
    }

    /// Executes a piped process. Piped processes must be executed in ascending order,
    /// starting with the first process in the pipe chain.
    /// - Parameter options: Additional user execution options
    /// - Returns: A `ShellResult` with a success or failure output
    public func execute(with options: Process.ExecuteOptions = .default) -> ShellResult {
        do {
            var chain: [Process] = [process]
            var parent = parent
            while let p = parent {
                chain.insert(p.process, at: 0)
                parent = p.parent
            }
            if options.contains(.silenceStandardOut) {
                chain.last?.standardOutput = nil
            }
            try chain.forEach { process in
                process.preRun(with: options)
                try process.run()
                process.waitUntilExit()
            }
            return try chain.last!.readOutputToResult(ignoringNoOutput: options.contains(.silenceStandardOut))
        } catch {
            return .failure(.init(status: .min, message: error.localizedDescription))
        }
    }

    public func piped(to wrapped: AnyProcess) -> PipedProcess {
        PipedProcess(wrapped.process, parent: self)
    }

}

extension Process: AnyProcess {

    /// Execution options used to add extra functionality to the
    /// ``AnyProcess/execute(with:)-1fw8h`` procedure
    public struct ExecuteOptions: OptionSet {

        /// The default options for `Process` execution
        public static let `default`: ExecuteOptions = [
            .terminateOnFailure
        ]

        public let rawValue: UInt
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        /// If inserted, will terminate on the first process faillure
        public static let terminateOnFailure = ExecuteOptions(rawValue: 1)

        /// Print every argument executed in the terminal (useful for debugging)
        public static let printArguments = ExecuteOptions(rawValue: 1 << 2)

        /// Silences the standard output pipe
        public static let silenceStandardOut = ExecuteOptions(rawValue: 1 << 3)
    }

    public var process: Process { self }

    public func piped(to wrapped: AnyProcess) -> PipedProcess {
        let connection = Pipe()
        standardOutput = connection
        wrapped.process.standardInput = connection
        wrapped.process.standardOutput = Pipe()
        return PipedProcess(wrapped.process, parent: PipedProcess(self))
    }

    /// Operations to execute prior to executing the process
    /// - Parameter options: The process execution options
    public func preRun(with options: ExecuteOptions) {
        guard options.contains(.printArguments) else { return }
        print(arguments?.joined(separator: " ") ?? "Empty args...")
    }

    public func execute(with options: Process.ExecuteOptions = .default) -> ShellResult {
        if options.contains(.silenceStandardOut) {
            standardOutput = nil
        }
        do {
            preRun(with: options)
            try run()
            waitUntilExit()
            return try readOutputToResult(ignoringNoOutput: options.contains(.silenceStandardOut))
        } catch {
            return .failure(.init(status: .min, message: error.localizedDescription))
        }
    }

    /// Reads the process output and transforms the output into a success or failure
    /// - Returns: A `ShellResult`
    func readOutputToResult(ignoringNoOutput: Bool = false) throws -> ShellResult {
        guard !ignoringNoOutput else {
            switch terminationStatus {
            case 0:
                return .success("")
            default:
                return .failure(.init(status: terminationStatus, message: "Terminated with exit code \(terminationStatus)"))
            }
        }
        guard let data = try (standardOutput as? Pipe)?.fileHandleForReading.readToEndCompat(),
              let output = String(data: data, encoding: .utf8) else {
            return .failure(.init(status: .min, message: "No data"))
        }
        switch terminationStatus {
        case 0:
            return .success(output)
        default:
            return .failure(.init(status: terminationStatus, message: output))
        }
    }
}

public extension Array where Element == AnyProcess {

    /// Executes an array of processes
    /// - Returns: The combined success of all processes or the first failure
    func executeAll(with options: Process.ExecuteOptions = .default) -> ShellResult {
        if options.contains(.terminateOnFailure) {
            var result: ShellResult = .empty
            for process in self {
                let execution = process.execute(with: options)
                guard case .success = execution else { return execution }
                result = result.combined(execution)
            }
            return result
        } else {
            return map { $0.execute(with: options) }
                .reduce(.empty, { $0.combined($1) })
        }
    }
}

/// A convenience struct to create an array of processes using `CommandBuilder`
public struct Processes {

    public internal(set) var value: [AnyProcess]

    public init(@CommandBuilder processes: () throws -> [AnyProcess]) {
        self.value = (try? processes()) ?? []
    }

    public func callAsFunction() -> [AnyProcess] { value }
}

public extension FileHandle {

    func readToEndCompat() throws -> Data? {
        guard #available(macOS 10.15.4, *) else {
            return readDataToEndOfFile()
        }
        return try readToEnd()
    }
}
