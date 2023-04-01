//
//  STDErrorOut.swift
//  
//
//  Created by casss-dev in 2023
//

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

public struct STDErrorOut: TextOutputStream {

    public init() {}

    public static var `default` = STDErrorOut()

    public mutating func write(_ string: String) { fputs(string, stderr)}
}
