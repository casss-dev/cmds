import XCTest
@testable import CMDS

final class CMDSTests: XCTestCase {

    func testCMDSHandlesSuccess() throws {
        // given
        let inputs = ["Hello", "World"]
        let cmds = CMDS {
            for input in inputs {
                echo(input)
            }
        }

        // when
        let output = try cmds.result.success

        // then
        XCTAssertEqual(cmds.result.status, 0)
        XCTAssertEqual(output, inputs.joined(separator: "\n") + "\n")
    }

    func testCMDSHandlesFailure() throws {
        // given
        let fakePath = "/Path/To/Directory/That/Does/Not/Exist"
        let cmds = CMDS {
            echo("Hello world")

            try cd(fakePath)
        }

        // when
        guard case .failure(let error) = cmds.result else {
            XCTFail("Expected a failure")
            return
        }

        // then
        let expected = ShError.cd(to: fakePath, invalidPathComponent: "Path")
        XCTAssertEqual(error.status, expected.status)
        XCTAssertEqual(error.localizedDescription, expected.localizedDescription)
    }

    func testPipedProcesses() throws {
        // given
        let echo = "echo 'these three words'"
        let sed = "sed 's/three //'"

        // when
        let piped = try (echo | sed)=|.success

        // then
        let expected = "these words\n"
        XCTAssertEqual(piped, expected)
    }
}
