//
//  Shell.swift
//
//
//  Created by casss-dev in 2023
//

import Foundation

public func sh(
    _ command: String,
    process: Process = .init(),
    stdIn: Pipe? = nil,
    stdOut: Pipe = Pipe(),
    stdErr: Pipe? = nil,
    config: CMDS.ShellConfig = CMDS.shellConfig
) -> Process {
    process.standardInput = stdIn
    process.standardOutput = stdOut
    process.standardError = stdErr ?? stdOut
    process.arguments = config.initialArguments + [command]
    process.executableURL = config.executableURL
    return process
}
