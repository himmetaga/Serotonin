import Foundation

public enum TouchAction: Equatable {
    case move(Vector2)
    case dash(Vector2)
    case stop
    case pause
}

/// Interprets a single-finger drag. Coordinates are screen points with positive y upwards.
/// In assisted mode, pull at least 95 points from the touch origin and hold a stable
/// direction for 0.65 seconds; turning or returning to neutral restarts that charge.
/// Move timestamps must be finite and strictly increase from begin/previous move. Tick
/// timestamps form a separate stream, must increase from the previous tick, and cannot
/// precede the latest touch sample. Duplicate or stale ticks are ignored; malformed or
/// reversed timestamps clear pending timed gestures.
public struct TouchInterpreter {
    private static let joystickRadius = 55.0
    private static let movementDeadzone = 8.0
    private static let pauseRadius = 8.0
    private static let pauseDuration = 0.75
    private static let normalDashDistance = 70.0
    private static let normalDashWindow = 0.20
    private static let normalDashMinimumTime = 0.025
    private static let normalDashMinimumSpeed = 350.0
    private static let assistedDashDistance = 95.0
    private static let assistedDashHold = 0.65
    private static let stableDirectionDot = 0.94
    private static let maximumPlausibleTimeStep = 10.0

    private let assisted: Bool
    private let sensitivity: Double

    private var isTracking = false
    private var origin = Vector2.zero
    private var startTime = 0.0
    private var lastTouchTime = 0.0
    private var lastTickTime: Double?
    private var movementActive = false
    private var dashEmitted = false
    private var pauseEligible = false
    private var pauseEmitted = false
    private var assistedDirection: Vector2?
    private var assistedChargeStart: Double?

    public init(assisted: Bool = false, sensitivity: Double = 1) {
        self.assisted = assisted
        self.sensitivity = sensitivity.isFinite ? min(max(sensitivity, 0), 4) : 1
    }

    public mutating func begin(at: Vector2, time: Double) {
        resetContact()
        guard isFinite(at), time.isFinite else { return }
        isTracking = true
        origin = at
        startTime = time
        lastTouchTime = time
        lastTickTime = nil
        pauseEligible = true
    }

    public mutating func move(to: Vector2, time: Double) -> [TouchAction] {
        guard isTracking else { return [] }
        guard isFinite(to), time.isFinite, time > lastTouchTime else {
            resetTimedGestures()
            return []
        }
        let step = time - lastTouchTime
        guard step.isFinite else {
            resetTimedGestures()
            return []
        }
        lastTouchTime = time

        let offset = to - origin
        guard isFinite(offset) else {
            resetTimedGestures()
            return []
        }

        if step > Self.maximumPlausibleTimeStep {
            resetTimedGestures()
        }

        let distance = offset.length
        guard distance.isFinite else {
            resetTimedGestures()
            return []
        }

        if distance > Self.pauseRadius {
            pauseEligible = false
        }

        var actions: [TouchAction] = []
        if distance > Self.movementDeadzone {
            movementActive = true
            actions.append(.move(movementVector(for: offset, distance: distance)))
        } else if movementActive {
            movementActive = false
            actions.append(.move(.zero))
        }

        if !dashEmitted {
            if assisted {
                updateAssistedCharge(offset: offset, distance: distance, time: time)
            } else {
                tryNormalDash(offset: offset, distance: distance, time: time, actions: &actions)
            }
        }

        return actions
    }

    public mutating func tick(time: Double) -> [TouchAction] {
        guard isTracking else { return [] }
        guard time.isFinite else {
            resetTimedGestures()
            return []
        }

        if let lastTickTime {
            if time == lastTickTime { return [] }
            guard time > lastTickTime else {
                resetTimedGestures()
                return []
            }
        }

        // Rendering can run ahead of a UIKit event timestamp. Ignore that stale frame
        // without changing either clock or the gesture charge.
        guard time >= lastTouchTime else { return [] }

        let previousTime = max(lastTouchTime, lastTickTime ?? lastTouchTime)
        let step = time - previousTime
        guard step.isFinite else {
            resetTimedGestures()
            return []
        }
        lastTickTime = time

        if step > Self.maximumPlausibleTimeStep {
            resetTimedGestures()
            return []
        }

        if pauseEligible, !pauseEmitted, time - startTime > Self.pauseDuration {
            pauseEmitted = true
            return [.pause]
        }

        if assisted, !dashEmitted,
           let chargeStart = assistedChargeStart,
           time - chargeStart >= Self.assistedDashHold,
           let direction = assistedDirection {
            dashEmitted = true
            return [.dash(direction)]
        }

        return []
    }

    public mutating func end() -> [TouchAction] {
        finishContact()
    }

    public mutating func cancel() -> [TouchAction] {
        finishContact()
    }

    private func movementVector(for offset: Vector2, distance: Double) -> Vector2 {
        let availableRadius = Self.joystickRadius - Self.movementDeadzone
        let response = min(max((distance - Self.movementDeadzone) / availableRadius, 0), 1)
        let scaled = offset.normalized * (response * sensitivity)
        let magnitude = scaled.length
        guard magnitude.isFinite else { return .zero }
        return magnitude > 1 ? scaled * (1 / magnitude) : scaled
    }

    private mutating func tryNormalDash(
        offset: Vector2,
        distance: Double,
        time: Double,
        actions: inout [TouchAction]
    ) {
        let elapsed = time - startTime
        guard elapsed.isFinite,
              elapsed >= Self.normalDashMinimumTime,
              elapsed <= Self.normalDashWindow,
              distance >= Self.normalDashDistance,
              distance / elapsed >= Self.normalDashMinimumSpeed else { return }

        dashEmitted = true
        actions.append(.dash(offset.normalized))
    }

    private mutating func updateAssistedCharge(offset: Vector2, distance: Double, time: Double) {
        guard distance >= Self.assistedDashDistance else {
            assistedDirection = nil
            assistedChargeStart = nil
            return
        }

        let direction = offset.normalized
        if let previous = assistedDirection,
           direction.x * previous.x + direction.y * previous.y >= Self.stableDirectionDot {
            return
        }

        assistedDirection = direction
        assistedChargeStart = time
    }

    private mutating func resetTimedGestures() {
        // A long or malformed gap cannot complete a timed gesture.
        pauseEligible = false
        assistedDirection = nil
        assistedChargeStart = nil
    }

    private mutating func finishContact() -> [TouchAction] {
        guard isTracking else { return [] }
        resetContact()
        return [.stop]
    }

    private mutating func resetContact() {
        isTracking = false
        origin = .zero
        startTime = 0
        lastTouchTime = 0
        lastTickTime = nil
        movementActive = false
        dashEmitted = false
        pauseEligible = false
        pauseEmitted = false
        assistedDirection = nil
        assistedChargeStart = nil
    }

    private func isFinite(_ vector: Vector2) -> Bool {
        vector.x.isFinite && vector.y.isFinite
    }
}
