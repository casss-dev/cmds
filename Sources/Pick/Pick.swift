//
//  Pick.swift
//  
//
//  Create by casss-dev in 2023
//

import Foundation
import ANSITerminal

/// A picker that returns a single option
public struct Pick<Option: RawRepresentable>: Picker where Option.RawValue == String, Option: Hashable {

    public var prompt: String
    public var options: [Option]
    public var extras: Extras<Option>
    public var styles: PickStyle = PickStyle()
    public var continueText: String = "Continue"
    public var maxChoice: Int = 1
    public var isMultipleChoice: Bool { maxChoice != 1 }
    public var validate: Validate<Option> = { _ in nil }

    public var lines: [Option: Int] = [:]
    public var activeIndex: Int
    public var selectedOptions: [Option] = []

    public init(
        prompt: String,
        options: [Option],
        activeOption: Option? = nil
    ) {
        precondition(!options.isEmpty, "Must provide at least one option to pick")
        self.prompt = prompt
        self.options = options
        self.extras = options.reduce(into: Extras(), {
            $0[$1] = .init()
        })
        if let activeOption, let i = options.firstIndex(of: activeOption) {
            self.activeIndex = i
        } else {
            self.activeIndex = 0
        }
    }

    /// Creates a multiple choice pick with a custom max amount of choices
    /// - Parameter max: The number of choices the user can select.
    /// - Returns: `self`
    @discardableResult public func multipleChoice(max: Int) -> MultiPick<Option> {
        var multi = MultiPick(self)
        multi.maxChoice = [max, options.count].max()!
        return multi
    }

    /// Creates a multiple choice pick with it's `maxChoice` equal to `options.count`
    public var multipleChoice: MultiPick<Option> {
        get {
            var multi = MultiPick(self)
            multi.maxChoice = options.count
            return multi
        }
    }

    /// Executes the picker
    /// - Returns: The selected option
    public func callAsFunction() -> Option {
        var mutable = self
        mutable.run()
        return mutable.selectedOptions.first!
    }

    /// Executes the picker and stores the result on a property
    /// - Parameter selected: The property to store the result on
    public func callAsFunction(storeOn selected: inout Option?) {
        selected = self()
    }
}

