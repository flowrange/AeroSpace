@testable import AppBundle
import Common
import XCTest

@MainActor
final class StickyLayoutTest: XCTestCase {
    override func setUp() async throws { setUpWorkspacesForTests() }

    func testShortcutTogglesStickyAndPreservesGeometry() async throws {
        let home = Workspace.get(byName: "sticky-home")
        let rect = Rect(topLeftX: 120, topLeftY: 80, width: 640, height: 360)
        let window = TestWindow.new(id: 1001, parent: home.rootTilingContainer, rect: rect)
        _ = window.focusWindow()
        let command = parseCommand("layout sticky floating").cmdOrDie

        _ = try await command.run(.defaultEnv, .emptyStdin)
        assertEquals(window.isSticky, true)
        assertEquals(window.isFloating, true)
        assertEquals(window.nodeWorkspace, home)
        assertEquals(try await window.getAxRect()?.topLeftCorner, rect.topLeftCorner)

        _ = try await command.run(.defaultEnv, .emptyStdin)
        assertEquals(window.isSticky, false)
        assertEquals(window.isFloating, true)
        assertEquals(try await window.getAxRect()?.size, rect.size)

        _ = try await command.run(.defaultEnv, .emptyStdin)
        assertEquals(window.isSticky, true)
    }

    func testFocusingStickyDoesNotReturnToHomeWorkspace() async throws {
        let home = Workspace.get(byName: "sticky-home")
        let destination = Workspace.get(byName: "sticky-destination")
        let window = TestWindow.new(id: 1001, parent: home)
        let browser = TestWindow.new(id: 1002, parent: destination.rootTilingContainer)
        window.isSticky = true
        _ = browser.focusWindow()

        assertEquals(window.nodeWorkspace, home)
        assertEquals(window.visualWorkspace, destination)
        _ = window.focusWindow()
        assertEquals(focus.workspace, destination)
        assertEquals(focus.windowOrNil, window)
        assertEquals(window.nodeWorkspace, home)
    }

    func testVisibleListIncludesStickyOnceAndExposesItsState() async throws {
        let home = Workspace.get(byName: "sticky-home")
        let destination = Workspace.get(byName: "sticky-destination")
        let window = TestWindow.new(id: 1001, parent: home)
        window.isSticky = true
        _ = TestWindow.new(id: 1002, parent: destination.rootTilingContainer).focusWindow()

        let result = try await parseCommand("list-windows --workspace visible --format '%{window-id} %{window-is-sticky}'")
            .cmdOrDie.run(.defaultEnv, .emptyStdin)
        assertEquals(result.stdout.toSet(), ["1001 true", "1002 false"])
        assertEquals(result.stdout.count, 2)

        window.isSticky = false
        let ordinary = try await parseCommand("list-windows --workspace visible --format '%{window-id}'")
            .cmdOrDie.run(.defaultEnv, .emptyStdin)
        assertEquals(ordinary.stdout, ["1002"])
    }

    func testStickyCommandIsIdempotentAndFloatingClearsIt() async throws {
        let window = TestWindow.new(id: 1001, parent: Workspace.get(byName: "sticky-home"))
        _ = window.focusWindow()
        let sticky = parseCommand("layout sticky").cmdOrDie
        _ = try await sticky.run(.defaultEnv, .emptyStdin)
        _ = try await sticky.run(.defaultEnv, .emptyStdin)
        assertEquals(window.isSticky, true)
        _ = try await parseCommand("layout floating").cmdOrDie.run(.defaultEnv, .emptyStdin)
        assertEquals(window.isSticky, false)
        assertEquals(window.isFloating, true)
    }
}
