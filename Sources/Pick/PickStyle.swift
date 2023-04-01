//
//  PickStyle.swift
//  
//
//  Create by casss-dev in 2023
//

import Foundation

/// A configuration for styling the picker
public struct PickStyle {

    public typealias Stylize = (_ text: String) -> String
    public typealias StylizeWithActive = (_ text: String, _ active: Bool) -> String
    public typealias ActiveStyle = (_ active: Bool) -> String

    /// The style of the default text
    public var text: StylizeWithActive = { text, active in
        active ? text.bold : text
    }

    /// An indicator prefixing the prompt
    public var promptIndicator: String = "◆".blue.bold

    /// The prompt style
    public var prompt: Stylize = { $0 }

    /// The check indicator to display for each option
    public var checkIndicator: ActiveStyle = { active in
        active ? "●".lightGreen : "○"
    }

    /// The color of the bar on the left hand side
    public var bar: Stylize = { $0 }
}
