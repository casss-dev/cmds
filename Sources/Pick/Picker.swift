//
//  Picker.swift
//  
//
//  Create by casss-dev in 2023
//

import ANSITerminal

/// Contains an optional prefix and suffix to attach to the option
public struct PickerOptionExtras {

    /// The prefix `String` interpolated before the option
    public var prefix: String

    /// The suffix `String` interpolated after the option
    public var suffix: String

    public init(
        prefix: String = "",
        suffix: String = ""
    ) {
        self.prefix = prefix
        self.suffix = suffix
    }

    public init(_ pickable: any Pickable) {
        self.prefix = pickable.prefix
        self.suffix = pickable.suffix
    }

    public func mutate(_ text: inout String) {
        if !prefix.isEmpty {
            text = prefix + " \(text)"
        }
        if !suffix.isEmpty {
            text = "\(text) " + suffix
        }
    }
}

/// The common interface for a pick
public protocol Picker {
    associatedtype Option: RawRepresentable, Hashable where Option.RawValue == String
    typealias Extras<Option> = [Option: PickerOptionExtras] where Option: Hashable
    typealias Validate<Option> = (_ selected: [Option]) -> String?

    // MARK: - Configuration
    /// The prompt to display to the user
    var prompt: String { get set }

    /// The options to choose from
    var options: [Option] { get set }
    
    /// Extra data associated with each option
    var extras: Extras<Option> { get set }

    /// A closure to call on the user input, returning a message to display
    /// if invalid (only used in multiple choice picks)
    var validate: Validate<Option> { get set }

    /// If this pick `isMultipleChoice` the continue text will be appended
    /// as a final option to allow the user to continue the flow of the program.
    var continueText: String { get set }

    /// The maximum number of choices for this pick.
    /// Zero or less, indicates as many choices as options
    var maxChoice: Int { get set }

    /// The styles for this picker
    var styles: PickStyle { get set }

    // MARK: - State
    /// The line in the terminal associated with the option
    var lines: [Option: Int] { get set }
    var activeIndex: Int { get set }
    var selectedOptions: [Option] { get set }

    // MARK: - Basic Init
    init(prompt: String, options: [Option], activeOption: Option?)

    // MARK: - Build
    /// Sets the prompt for the user
    /// - Parameter text: The `prompt` to set
    /// - Returns: `self`
    @discardableResult mutating func setPrompt(_ text: String) -> Self

    /// Sets `continueText`, used when this picker is multiple choice.
    /// - Parameter text: The displayed `continueText`
    /// - Returns: `self`
    @discardableResult mutating func setContinue(text: String) -> Self

    /// Sets `styles` for this picker
    /// - Parameter style: The style to set
    /// - Returns: `self`
    @discardableResult mutating func setStyle(_ style: PickStyle) -> Self

    /// Sets `extras` for this picker
    /// - Parameter extras: The extras to set
    /// - Returns: `self`
    @discardableResult mutating func setExtras(_ extras: Extras<Option>) -> Self
}

public extension Picker {

    init(_ pickable: Option.Type, activeOption: Option? = nil) where Option: Pickable {
        precondition(!pickable.allCases.isEmpty, "Must provide at least one option")
        self.init(
            prompt: pickable.prompt,
            options: pickable.allCases as! [Option],
            activeOption: activeOption
        )
        extras = (pickable.allCases as! [Option]).reduce(into: Extras(), {
            $0[$1] = PickerOptionExtras(prefix: $1.prefix, suffix: $1.suffix)
        })
        let activeOption = activeOption ?? pickable.allCases.first!
        if let i = options.firstIndex(of: activeOption) {
            self.activeIndex = i
        }
    }

    /// The option the cursor is on or nil if `continueText` is selected
    var activeOption: Option? {
        guard options.indices.contains(activeIndex) else { return nil }
        return options[activeIndex]
    }

    var isMultipleChoice: Bool { maxChoice != 1 }

    var continueRow: Int { lines.values.max()! + 1 }
    var continueActive: Bool { activeIndex == options.count }

    static var indicatorCol: Int { 3 }
    static var textCol: Int { 5 }

    @discardableResult mutating func setPrompt(_ text: String) -> Self {
        prompt = text
        return self
    }

    @discardableResult mutating func setContinue(text: String) -> Self {
        continueText = text
        return self
    }

    @discardableResult mutating func setStyle(_ style: PickStyle) -> Self {
        styles = style
        return self
    }

    @discardableResult mutating func setExtras(_ extras: Extras<Option>) -> Self {
        self.extras = extras
        return self
    }

    @discardableResult mutating func validate(when validation: @escaping Validate<Option>) -> Self {
        validate = validation
        return self
    }

    /// Runs the picker
    internal mutating func run() {
        cursorOff()
        render()

        while true {
            clearBuffer()

            guard keyPressed() else { continue }

            let char = readChar()
            guard char != NonPrintableChar.enter.char() else {
                if isMultipleChoice {
                    // If active option is nil, the continue option was selected.
                    guard let activeOption else {
                        if let errorMsg = validate(selectedOptions) {
                            writeError(errorMsg)
                            continue
                        }
                        break
                    }
                    if let i = selectedOptions.firstIndex(of: activeOption) {
                        selectedOptions.remove(at: i)
                    } else {
                        selectedOptions.append(activeOption)
                    }
                    render(reRender: true)
                    continue
                } else {
                    guard let activeOption else {
                        assertionFailure("Active option should never be nil in a single choice configuration")
                        break
                    }
                    selectedOptions.append(activeOption)
                    break
                }
            }

            let key = readKey()
            switch (key.code, char) {
            case (.up, _) where activeIndex > 0, (_, "k") where activeIndex > 0:
                activeIndex -= 1
                render(reRender: true)
            case (.down, _) where activeIndex < options.count - (isMultipleChoice ? 0 : 1), (_, "j") where activeIndex < options.count - (isMultipleChoice ? 0 : 1):
                activeIndex += 1
                render(reRender: true)
            default:
                break
            }
        }

        moveLineDown()
        cursorOn()
    }

    fileprivate func writeError(_ msg: String) {
        writeAt(
            continueRow,
            Self.textCol + continueText.count + 1,
            msg
        )
    }

    /// Renders the picker
    /// - Parameter reRender: If `true`, will perform a re-render of changes
    fileprivate mutating func render(reRender: Bool = false) {
        defer {
            if isMultipleChoice {
                writeAt(continueRow, Self.textCol, styles.text(continueText, continueActive))
                moveLineDown()
            }
        }
        guard !reRender else {
            options.forEach { renderOption($0, reRender: true) }
            return
        }
        moveLineDown()

        write(styles.promptIndicator)

        moveRight()
        write(styles.prompt(prompt))

        options.forEach { renderOption($0) }

        moveLineDown()
        write(styles.bar("└"))
        moveLineDown()
    }

    /// Renders the specified option
    /// - Parameters:
    ///   - option: The option to render
    ///   - reRender: If `true`, will perform a re-render of changes
    fileprivate mutating func renderOption(_ option: Option, reRender: Bool = false) {

        if !reRender { lines[option] = readCursorPos().row + 1 }

        guard let line = lines[option] else {
            fatalError("Failed to find \(option.rawValue) in options list")
        }
        let isActive = option == activeOption
        let isSelected = isMultipleChoice ? selectedOptions.contains(option) : isActive

        let checkIndicator = styles.checkIndicator(isSelected)

        var text = styles.text(option.rawValue, isActive)

        extras[option]?.mutate(&text)

        if reRender {
            writeAt(line, Self.indicatorCol, checkIndicator)
            writeAt(line, Self.textCol, text)
        } else {
            moveLineDown()
            write(styles.bar("|"))
            moveRight()
            write(checkIndicator)

            moveRight()
            write(text)
        }
    }

    /// Write to stdout at the specified row and column
    /// - Parameters:
    ///   - row: The row
    ///   - col: The column
    ///   - text: The text to write to stdout
    fileprivate func writeAt(_ row: Int, _ col: Int, _ text: String) {
        moveTo(row, col)
        write(text)
    }
}

