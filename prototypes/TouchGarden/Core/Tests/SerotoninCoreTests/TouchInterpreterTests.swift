import XCTest
@testable import SerotoninCore

final class TouchInterpreterTests: XCTestCase {
    func testSlowDragMovesWithoutDashing() {
        var input = TouchInterpreter()
        input.begin(at: .zero, time: 0)

        let actions = input.move(to: Vector2(x: 80, y: 0), time: 0.5)

        XCTAssertEqual(actions, [.move(Vector2(x: 1, y: 0))])
    }

    func testReturningToDeadzoneEmitsNeutralMovement() {
        var input = TouchInterpreter()
        input.begin(at: .zero, time: 0)
        _ = input.move(to: Vector2(x: 30, y: 0), time: 0.1)

        XCTAssertEqual(input.move(to: Vector2(x: 4, y: 0), time: 0.2), [.move(.zero)])
        XCTAssertEqual(input.move(to: Vector2(x: 2, y: 0), time: 0.3), [])
    }

    func testIntentionalEarlySwipeDashesInSwipeDirection() {
        var input = TouchInterpreter()
        input.begin(at: .zero, time: 0)

        let actions = input.move(to: Vector2(x: 72, y: 0), time: 0.15)

        XCTAssertTrue(actions.contains(.dash(Vector2(x: 1, y: 0))))
    }

    func testFastSteeringAfterInitialWindowNeverDashes() {
        var input = TouchInterpreter()
        input.begin(at: .zero, time: 0)
        _ = input.move(to: Vector2(x: 12, y: 0), time: 0.1)

        let actions = input.move(to: Vector2(x: 100, y: 0), time: 0.25)

        XCTAssertFalse(actions.contains { if case .dash = $0 { true } else { false } })
    }

    func testNormalDashCanHappenOnlyOncePerContact() {
        var input = TouchInterpreter()
        input.begin(at: .zero, time: 0)
        let first = input.move(to: Vector2(x: 75, y: 0), time: 0.1)
        let second = input.move(to: Vector2(x: 0, y: 100), time: 0.15)

        XCTAssertEqual(first.filter { if case .dash = $0 { true } else { false } }.count, 1)
        XCTAssertFalse(second.contains { if case .dash = $0 { true } else { false } })
    }

    func testEndAndCancelOnlyStopAndNeverDash() {
        var ended = TouchInterpreter()
        ended.begin(at: .zero, time: 0)
        _ = ended.move(to: Vector2(x: 40, y: 0), time: 0.1)
        XCTAssertEqual(ended.end(), [.stop])
        XCTAssertEqual(ended.end(), [])

        var cancelled = TouchInterpreter()
        cancelled.begin(at: .zero, time: 0)
        _ = cancelled.move(to: Vector2(x: 40, y: 0), time: 0.1)
        XCTAssertEqual(cancelled.cancel(), [.stop])
    }

    func testPauseIsOneShotAndMovementCancelsIt() {
        var held = TouchInterpreter()
        held.begin(at: .zero, time: 0)
        XCTAssertEqual(held.tick(time: 0.74), [])
        XCTAssertEqual(held.tick(time: 0.75), [])
        XCTAssertEqual(held.tick(time: 0.751), [.pause])
        XCTAssertEqual(held.tick(time: 1), [])

        var moved = TouchInterpreter()
        moved.begin(at: .zero, time: 0)
        _ = moved.move(to: Vector2(x: 9, y: 0), time: 0.2)
        XCTAssertEqual(moved.tick(time: 1), [])
    }

    func testAssistedChargeNeedsStableDirectionAndReleaseCancels() {
        var input = TouchInterpreter(assisted: true)
        input.begin(at: .zero, time: 0)
        let movement = input.move(to: Vector2(x: 100, y: 0), time: 0.1)
        XCTAssertTrue(movement.contains { if case .move = $0 { true } else { false } })
        XCTAssertEqual(input.tick(time: 0.74), [])
        XCTAssertEqual(input.tick(time: 0.76), [.dash(Vector2(x: 1, y: 0))])
        XCTAssertEqual(input.tick(time: 1), [])

        XCTAssertEqual(input.end(), [.stop])
        input.begin(at: .zero, time: 2)
        _ = input.move(to: Vector2(x: 100, y: 0), time: 2.1)
        _ = input.move(to: Vector2(x: 0, y: 0), time: 2.2)
        XCTAssertEqual(input.tick(time: 3), [])
        XCTAssertEqual(input.cancel(), [.stop])
    }

    func testAssistedFastSwipeDoesNotUseNormalDash() {
        var input = TouchInterpreter(assisted: true)
        input.begin(at: .zero, time: 0)

        let swipe = input.move(to: Vector2(x: 100, y: 0), time: 0.1)

        XCTAssertFalse(swipe.contains { if case .dash = $0 { true } else { false } })
        XCTAssertEqual(input.tick(time: 0.2), [])
    }

    func testInterleavedTouchSampleCanPrecedeLatestRenderTick() {
        var assisted = TouchInterpreter(assisted: true)
        assisted.begin(at: .zero, time: 0)
        _ = assisted.move(to: Vector2(x: 100, y: 0), time: 0.1)
        XCTAssertEqual(assisted.tick(time: 0.2), [])

        let changedPosition = assisted.move(to: Vector2(x: 99, y: 10), time: 0.19)
        XCTAssertTrue(changedPosition.contains { if case .move = $0 { true } else { false } })
        XCTAssertEqual(assisted.tick(time: 0.76), [.dash(Vector2(x: 1, y: 0))])

        var normal = TouchInterpreter()
        normal.begin(at: .zero, time: 0)
        _ = normal.move(to: Vector2(x: 10, y: 0), time: 0.1)
        XCTAssertEqual(normal.tick(time: 0.16), [])

        let delayedSwipe = normal.move(to: Vector2(x: 75, y: 0), time: 0.15)
        XCTAssertTrue(delayedSwipe.contains(.dash(Vector2(x: 1, y: 0))))
    }

    func testAssistedDirectionChangeRestartsChargeAndNeutralResetsIt() {
        var input = TouchInterpreter(assisted: true)
        input.begin(at: .zero, time: 0)
        _ = input.move(to: Vector2(x: 100, y: 0), time: 0.1)
        _ = input.move(to: Vector2(x: 0, y: 100), time: 0.5)
        XCTAssertEqual(input.tick(time: 1.14), [])
        XCTAssertEqual(input.tick(time: 1.16), [.dash(Vector2(x: 0, y: 1))])

        var neutral = TouchInterpreter(assisted: true)
        neutral.begin(at: .zero, time: 0)
        _ = neutral.move(to: Vector2(x: 100, y: 0), time: 0.1)
        _ = neutral.move(to: Vector2(x: 10, y: 0), time: 0.3)
        _ = neutral.move(to: Vector2(x: 100, y: 0), time: 0.4)
        XCTAssertEqual(neutral.tick(time: 1), [])
    }

    func testMalformedAndNonmonotonicTimesDoNotProduceTimedActions() {
        var input = TouchInterpreter()
        input.begin(at: .zero, time: 0)
        XCTAssertEqual(input.move(to: Vector2(x: 100, y: 0), time: 0), [])
        XCTAssertEqual(input.move(to: Vector2(x: 100, y: 0), time: .nan), [])
        XCTAssertEqual(input.move(to: Vector2(x: 100, y: 0), time: -1), [])
        XCTAssertEqual(input.tick(time: .infinity), [])
        XCTAssertEqual(input.tick(time: 20), [])
    }

    func testMalformedOrLongGapResetsPendingAssistedCharge() {
        var malformed = TouchInterpreter(assisted: true)
        malformed.begin(at: .zero, time: 0)
        _ = malformed.move(to: Vector2(x: 100, y: 0), time: 0.1)
        XCTAssertEqual(malformed.tick(time: .nan), [])
        XCTAssertEqual(malformed.tick(time: 0.9), [])

        var longGap = TouchInterpreter(assisted: true)
        longGap.begin(at: .zero, time: 0)
        _ = longGap.move(to: Vector2(x: 100, y: 0), time: 0.1)
        XCTAssertEqual(longGap.tick(time: 11), [])
        XCTAssertEqual(longGap.tick(time: 11.7), [])
    }

    func testDuplicateTickIsNoOpAndPreservesAssistedCharge() {
        var input = TouchInterpreter(assisted: true)
        input.begin(at: .zero, time: 0)
        _ = input.move(to: Vector2(x: 100, y: 0), time: 0.1)

        XCTAssertEqual(input.tick(time: 0.2), [])
        XCTAssertEqual(input.tick(time: 0.2), [])
        XCTAssertEqual(input.tick(time: 0.76), [.dash(Vector2(x: 1, y: 0))])
    }

    func testCancelThenNewContactCanDashAgain() {
        var input = TouchInterpreter()
        input.begin(at: .zero, time: 0)
        let first = input.move(to: Vector2(x: 75, y: 0), time: 0.1)
        XCTAssertTrue(first.contains { if case .dash = $0 { true } else { false } })
        XCTAssertEqual(input.cancel(), [.stop])

        input.begin(at: .zero, time: 1)
        let second = input.move(to: Vector2(x: 0, y: 75), time: 1.1)
        XCTAssertTrue(second.contains(.dash(Vector2(x: 0, y: 1))))
    }

    func testMovementMagnitudeIsCappedAcrossSensitivitiesAndDiagonals() {
        for (sensitivity, expectedMagnitude) in [(0.5, 0.5), (1.0, 1.0), (4.0, 1.0)] {
            var input = TouchInterpreter(sensitivity: sensitivity)
            input.begin(at: .zero, time: 0)
            let actions = input.move(to: Vector2(x: 100, y: 100), time: 0.1)

            guard let movement = actions.compactMap({ action -> Vector2? in
                if case let .move(vector) = action { return vector }
                return nil
            }).first else {
                XCTFail("Expected a diagonal movement action")
                continue
            }

            XCTAssertEqual(movement.length, expectedMagnitude, accuracy: 1e-12)
            XCTAssertLessThanOrEqual(abs(movement.x), 1)
            XCTAssertLessThanOrEqual(abs(movement.y), 1)
        }
    }

    func testVectorZeroNormalizationAndArithmetic() {
        XCTAssertEqual(Vector2.zero.length, 0)
        XCTAssertEqual(Vector2.zero.normalized, .zero)
        XCTAssertEqual(Vector2(x: 3, y: 4).length, 5)
        let normalized = Vector2(x: 3, y: 4).normalized
        XCTAssertEqual(normalized.x, 0.6, accuracy: 1e-12)
        XCTAssertEqual(normalized.y, 0.8, accuracy: 1e-12)
        XCTAssertEqual(Vector2(x: 1, y: 2) + Vector2(x: 3, y: 4), Vector2(x: 4, y: 6))
        XCTAssertEqual(Vector2(x: 4, y: 6) - Vector2(x: 3, y: 4), Vector2(x: 1, y: 2))
        XCTAssertEqual(Vector2(x: 2, y: -3) * 2, Vector2(x: 4, y: -6))
    }
}
