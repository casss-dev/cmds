//
//  MultiPick.swift
//  
//
//  Create by casss-dev in 2023
//

import Foundation
import ANSITerminal

/// A picker that returns multiple options
public struct MultiPick<Option: RawRepresentable>: Picker where Option.RawValue == String, Option: Hashable {

    public var prompt: String
    public var options: [Option]
    public var extras: Extras<Option>
    public var continueText: String = "Continue"
    public var styles: PickStyle = PickStyle()
    public var maxChoice: Int = 2
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

    public init(_ picker: Pick<Option>) {
        self.prompt = picker.prompt
        self.options = picker.options
        self.extras = picker.extras
        self.maxChoice = picker.maxChoice
        self.continueText = picker.continueText
        self.activeIndex = picker.activeIndex
        self.selectedOptions = picker.selectedOptions
        self.lines = picker.lines
        self.styles = picker.styles
    }

    /// Configure multiple choice count
    /// - Parameter max: The number of choices the user can select.
    /// If nil, the maximum amount of choices will be equal to the number of options
    /// - Returns: `self`
    @discardableResult public mutating func multiChoice(max: Int? = nil) -> Self {
        if let max { maxChoice = [max, options.count].max()! }
        else { maxChoice = options.count }
        return self
    }

    /// Executes the picker
    /// - Returns: The selected options
    public func callAsFunction() -> [Option] {
        var mutable = self
        mutable.run()
        return mutable.selectedOptions
    }

    /// Executes the picker and stores the results on a property
    /// - Parameter selected: The property to store the results on
    public func callAsFunction(storeOn selected: inout [Option]?) {
        selected = self()
    }
}

