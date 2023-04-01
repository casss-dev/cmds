//
//  ShellResult.swift
//  
//
//  Created by casss-dev in 2023
//

import Foundation

/// A shell error containing the process exit code and message
public struct ShError: Swift.Error {
    /// The exit code of the shell process
    public var status: Int32
    /// The message associated with the error
    public var message: String
}

extension ShError: LocalizedError {

    public var errorDescription: String? {
        message
    }
}

/// A result returning a `String` on success or `ShError` on failure
public typealias ShellResult = Result<String, ShError>

public extension ShellResult {

    var status: Int32 {
        switch self {
        case .success:
            return 0
        case .failure(let error):
            return error.status
        }
    }

    /// Empty successful `ShellResult`
    static var empty: Self { .success("") }

    /// The success value, throwing the error on failure
    var success: String {
        get throws {
            switch self {
            case .success(let output):
                return output
            case .failure(let error):
                throw error
            }
        }
    }

    /// Combines all std out and std error into one successful result
    /// - Parameter other: The other result to combine with
    /// - Returns: A `ShellResult.success` with interleaved error messages
    func combined(_ other: ShellResult) -> ShellResult {
        switch self {
        case .success(let output):
            switch other {
            case .success(let other):
                return .success(output + other)
            case .failure(let err):
                return .success(output + err.message)
            }
        case .failure(let error):
            switch other {
            case .success(let output):
                return .success(error.message + output)
            case .failure(let otherError):
                return .success(error.message + otherError.message)
            }
        }
    }
}
