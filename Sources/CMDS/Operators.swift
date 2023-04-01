//
//  Operators.swift
//  
//
//  Created by casss-dev in 2023
//

import Foundation

infix operator |: AdditionPrecedence
public func | (left: AnyProcess, right: AnyProcess) -> PipedProcess {
    left.piped(to: right.process)
}

postfix operator =|
public postfix func =| (left: AnyProcess) -> ShellResult {
    left.execute(with: CMDS.optionsQueue.first ?? .default)
}
