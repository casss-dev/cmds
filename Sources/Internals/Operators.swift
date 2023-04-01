//
//  Operators.swift
//  
//
//  Created by casss-dev in 2023
//

import Foundation

public protocol Initializable { init() }
extension String: Initializable { }

infix operator &&&
public func &&& <T>(left: Optional<T>, right: @autoclosure () -> T) -> T where T: Initializable {
    if left != nil { return right() }
    return T()
}

public func &&& <T>(left: Bool, right: @autoclosure () -> T) -> T where T: Initializable {
    if left { return right() }
    return T()
}
