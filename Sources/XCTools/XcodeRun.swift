//
//  XcodeRun.swift
//  
//
//  Created by casss-dev in 2023
//

import Foundation
import CMDS
import Internals

public struct XCRun: AnyProcess {
    public var arguments: Arguments

    public init(_ arguments: Arguments) {
        self.arguments = arguments
    }

    public var process: Process {
        """
        xcrun \(arguments)
        """.process
    }
}

public extension XCRun {

    enum Arguments: CustomStringConvertible {
        case simctl(SimCtl)

        public var description: String {
            switch self {
            case .simctl(let subOption):
                return "simctl \(subOption)"
            }
        }
    }

    enum SimCtl: CustomStringConvertible {
        case install(Install)
        case launch(Launch)

        public var description: String {
            switch self {
            case .install(let install):
                return install.description
            case .launch(let launch):
                return launch.description
            }
        }
    }

    struct Install: CustomStringConvertible {
        public var simulator: String
        public var appPath: String

        public init(simulator: String, appPath: String) {
            self.simulator = simulator
            self.appPath = appPath
        }

        public init(simulator: Simulator, appPath: String) {
            self.simulator = simulator.description
            self.appPath = appPath
        }

        public var description: String {
            "'\(simulator)' '\(appPath)'"
        }
    }

    struct Launch: CustomStringConvertible {
        public var simulator: String
        public var bundleIdentifier: String

        public init(simulator: String, bundleIdentifier: String) {
            self.simulator = simulator
            self.bundleIdentifier = bundleIdentifier
        }

        public init(simulator: Simulator, bundleIdentifier: String) {
            self.simulator = simulator.description
            self.bundleIdentifier = bundleIdentifier
        }

        public var description: String {
            "'\(simulator)' '\(bundleIdentifier)'"
        }
    }

}

public enum Simulator: CustomStringConvertible {
    case booted

    case iPhone(version: Int, pro: Bool = false, size: Size = .regular)

    public var description: String {
        switch self {
        case .booted:
            return "booted"
        case .iPhone(version: let version, pro: let isPro, size: let size):
            return "iPhone \(version)\(isPro &&& " Pro")\(size)"
        }
    }
}

public extension Simulator {

    enum Size: CustomStringConvertible {
        case regular
        case max

        public var description: String {
            switch self {
            case .regular:
                return ""
            case .max:
                return " Max"
            }
        }
    }
}
