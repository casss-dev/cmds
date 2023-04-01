//
//  XcodeBuild.swift
//  
//
//  Created by casss-dev in 2023
//

import Foundation
import CMDS
import Internals

public struct XCBuild: AnyProcess {

    public var xcFile: XCFile
    public var scheme: String
    public var configuration: String
    public var destination: Destination
    public var derivedDataPath: String
    public var clean: Bool

    public init(
        xcFile: XCFile,
        scheme: String,
        configuration: String,
        destination: Destination,
        derivedDataPath: String? = nil,
        clean: Bool = false
    ) {
        self.xcFile = xcFile
        self.scheme = scheme
        self.configuration = configuration
        self.destination = destination
        self.derivedDataPath = derivedDataPath ?? "$HOME/Library/Developer/Xcode/DerivedData"
        self.clean = clean
    }

    public init(
        xcFile: XCFile,
        scheme: String,
        configuration: DefaultConfiguration,
        destination: Destination,
        derivedDataPath: String? = nil,
        clean: Bool = false
    ) {
        self.xcFile = xcFile
        self.scheme = scheme
        self.configuration = configuration.description
        self.destination = destination
        self.derivedDataPath = derivedDataPath ?? "$HOME/Library/Developer/Xcode/DerivedData"
        self.clean = clean
    }

    public var process: Process {
        """
        xcodebuild \(clean &&& "clean") \(xcFile) \
        -scheme \(scheme) \
        -configuration \(configuration) \
        -destination \(destination) \
        -derivedDataPath \(derivedDataPath)
        """.process
    }
}

extension XCBuild {

    public enum XCFile: CustomStringConvertible {
        case project(String)
        case workspace(String)

        public var description: String {
            switch self {
            case .project(var project):
                project = project.replacingOccurrences(of: ".xcodeproj", with: "")
                return "-project \(project).xcodeproj"
            case .workspace(var workspace):
                workspace = workspace.replacingOccurrences(of: ".xcworkspace", with: "")
                return "-workspace \(workspace).xcworkspace"
            }
        }
    }

    public enum DefaultConfiguration: String, CustomStringConvertible {
        case debug
        case release

        public var description: String {
            switch self {
            case .debug:
                return rawValue.uppercased()
            case .release:
                return rawValue.uppercased()
            }
        }
    }

    public struct Destination: CustomStringConvertible {
        public var platform: String
        public var name: String
        public var os: String?

        public init(
            platform: String,
            name: String,
            os: String? = nil
        ) {
            self.platform = platform
            self.name = name
            self.os = os
        }

        public init(
            platform: Platform,
            name: String,
            os: String? = nil
        ) {
            self.platform = platform.description
            self.name = name
            self.os = os
        }

        public init(
            simulator: Simulator,
            os: String? = nil
        ) {
            self.platform = Platform.iOSSimulator.description
            self.name = simulator.description
            self.os = os
        }

        public var description: String {
            "'platform=\(platform),name=\(name)\(os &&& "OS=\(os!)")'"
        }
    }

    public enum Platform: CustomStringConvertible {
        case iOSSimulator
        case macOS

        public var description: String {
            switch self {
            case .iOSSimulator:
                return "iOS Simulator"
            case .macOS:
                return "macOS"
            }
        }
    }
}
