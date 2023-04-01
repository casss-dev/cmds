//
//  StaticProcess.swift
//
//
//  Created by casss-dev in 2023
//

import Foundation

public func echo(_ msg: some StringProtocol) -> AnyProcess {
    "echo '\(msg)'"
}

extension ShError {

    public static func cd(to path: String, invalidPathComponent: String) -> ShError {
        ShError(
            status: .min,
            message: "Failed to set current directory to '\(path)'\n\(invalidPathComponent)' does not exist"
        )
    }
}

public func cd(_ path: String) throws -> AnyProcess {
    if !FileManager.default.changeCurrentDirectoryPath(path) {
        var checkedPath: String = ""
        var isDir: ObjCBool = true
        for component in path.split(separator: "/") {
            checkedPath += component
            if !FileManager.default.fileExists(atPath: checkedPath, isDirectory: &isDir) {
                throw ShError.cd(to: path, invalidPathComponent: String(component))
            }
        }
    }
    return ""
}

public var pwd: String {
    FileManager.default.currentDirectoryPath
}

public var home: String {
    FileManager.default.homeDirectoryForCurrentUser.absoluteString
}

public func plistBuddy(_ command: String) -> AnyProcess {
    "/usr/libexec/PlistBuddy \(command)"
}
