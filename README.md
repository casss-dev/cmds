<br/>

![CMDS_Banner](docs/CMDS_Banner.png)

**CMDS** is a robust swift library designed to make scripting in swift _much_
simpler.

Write your shell scripts without having to worry about verbose implementation
details when creating and executing processes.

## About

**CMDS** includes several declarative utility APIs to help create user-friendly
CLI interfaces.

## Getting Started

To get started with CMDS, all you have to do is import it, and wrap your script
using the `CMDS` API:

```swift
import CMDS

CMDS {

  "echo 'Hello world! 👋'"

}()
```

`CMDS` uses a result builder, so custom logic can be seamlessly intertwined
within your script. In addition, several operators have been added to make the
syntax feel akin to normal bash scripting:

```swift
CMDS {

  for i in 0...10 {
      "touch \(i).txt"
  }

  if case .success(let pipedOutput) = ("someCommand" | "pipedToAnotherCommand")=| {
    "echo \(pipedOutput)"
  } else {
    "exit 1"
  }

}()
```

### Static Processes

Static processes are included as well to give extra type-safety and help when
debugging:

```swift
CMDS {

  try cd("/Path/To/MyXcodeProject")

  plistBuddy("Print Info.plist")

  XCBuild(
    xcFile: .workspace("MyXcodeProject"),
    scheme: "Debug",
    configuration: "Development",
    destination: .init(simulator: .booted, os: "16"),
  )
}()
```

> These commands are a work in progress. If you'd like to see more static
> commands, feel free to submit a PR.

### Out of Context

If you need to execute shell commands outside of the `CMDS` result builder
context, you can do so using the `process` extension:

```swift
func run() throws {

  let myIndependentProcess = "curl https://www.google.com".process

  // OR...
  let myInferredProcess: AnyProcess = "curl https://www.yahoo.com"

  let result = myInferredProcess.execute()
  switch result {
  case .success(let output):
      print(output)
  case .failure(let error):
      print(error.localizedDescription)
  }
}
```

## Pick

**Pick** contains APIs for getting a choice or several choices from a user based
on radio input.

The easiest way to get a choice from the users is to declare an `enum` that
conforms to `String` & `Pickable`. Doing so attaches the `pick` property
allowing you to build a picker and simply execute the prompt to the user to
acquire the user's choice in a type-safe way.

```swift
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
    case .red:
        print("Be our guest!")
    case .green:
        print("They're magically delicious!")
    case .blue:
        print("Call me Ishmael.")
 }
```

## ProgressBar

**ProgressBar** lets you declaratively write code that will display in the
terminal as a progress bar. Progress calculations are made possible by prefixing
statements with a `*` operator, which wraps the statement in an autoclosure so
it can be tallied before execution.

> Note: each line of code represents an equal portion of the total progress.

```swift
 ProgressBar {
    *sleep(2)
    // progress = 25%

    *sleep(1)
    // progress = 50%

    *sleep(3)
    // progress = 75%

    *sleep(5)
    // progress = 100%
 }
```

### ProgressBar Styling

**ProgressBar** can be styled by modifying the style of the injected
`ProgressPrinter`. To style, simply modify the leading, mid, or trailing
closures of the style callbacks to output your desired string.

```swift
let printer = ProgressPrinter(
    styles: .init(
        barLeading: { _, _ in
            "Begin bar ["
        }, barMid: { percent, totalWidth in
            let barFill = Int(round(percent * Double(totalWidth)))

            let barIcon = "#"

            let bar = Array(repeating: barIcon, count: barFill)
                .joined(separator: "")

            let emptySpace = Array(repeating: " ", count: totalWidth - barFill)
                .joined(separator: "")

            return bar + emptySpace
        }, barTrailing: { _, _ in
            "] End bar"
        })
)

ProgressBar(printer: printer) {

    *tallyThisTask()

    *andThisTask()
}()
```
