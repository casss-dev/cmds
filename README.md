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
