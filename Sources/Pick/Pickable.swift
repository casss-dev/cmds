//
//  Pickable.swift
//  
//
//  Create by casss-dev in 2023
//

import Foundation

/**
 `Pickable` is a type-safe declarative API to get a choice from the user. When an `enum` conforms
 to `Pickable` a `pick` method is attached, providing a declarative syntax to customize the picker.

 ```
enum FavoriteColor: String, Pickable {

    static public var prompt: String { "What's your favorite color?" }

    case red, green, blue

    public var prefix: String {
        switch self {
        case .red:
            return "🌹"
        case .green:
            return "☘️"
        case .blue:
            return "🐳"
        }
    }
}

 let fav = FavoriteColor.pick()

 switch fav {
     case .blue:
         print("Everyone likes blue!")
     default:
         print("Good Choice!")
 }
 ```
 */
public protocol Pickable: RawRepresentable, CaseIterable, Hashable, CustomStringConvertible where RawValue == String {
    /// The prompt to display to the user
    static var prompt: String { get }

    /// An optional prefix string for each case
    var prefix: String { get }

    /// An optional suffix string for each case
    var suffix: String { get }

    /// Creates a `Pick` from the `Pickable` enumeration
    static var pick: Pick<RawValue> { get set } // needs a setter because invocation is mutable
}

public extension Pickable {

    var prefix: String { "" }
    var suffix: String { "" }

    /// Creates a `Pick` from this enumeration.
    /// After customization is complete, invoke to display
    /// the options to the user and collect input.
    static var pick: Pick<RawValue> {
        get { Pick(Self.self) }
        @available(*, unavailable, message: "This property is read only")
        set {}
    }

    /// The string representing this pick, displayed to the user
    var description: String {
        var value = rawValue
        PickerOptionExtras(self).mutate(&value)
        return value
    }
}

public extension Sequence where Element: StringProtocol {

    func pick(withPrompt prompt: String) -> Pick<Element> {
        Pick<Element>(prompt: prompt, options: Array(self))
    }
}
