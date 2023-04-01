//
//  Tally.swift
//  
//
//  Created by casss-dev in 2023
//

import Foundation

prefix operator *
public prefix func *<T>(
    rightSide: @autoclosure @escaping () -> T
) -> any Talliable {
    Tally(rightSide)
}

public func tally<T>(
    _ statement: @autoclosure @escaping () -> T,
    message: String? = nil
) -> any Talliable {
    Tally(statement, message: message)
}

public protocol Talliable {
    associatedtype ReturnType
    var closure: () -> ReturnType { get }
    var message: String? { get }

    init(
        _ closure: @autoclosure @escaping () -> ReturnType,
        message: String?
    )
}

fileprivate struct Tally<ReturnType>: Talliable {

    var closure: () -> ReturnType
    var message: String?

    init(
        _ closure: @escaping () -> ReturnType,
        message: String? = nil
    ) {
        self.closure = closure
        self.message = message
    }
}
