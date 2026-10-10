import UIKit
import SpriteKit
import SerotoninCore
import QuartzCore

enum SceneEvent {
    case objective(String)
    case feedback(FeedbackKind)
    case paused
    case completed
    case telemetry(String)
}

enum FeedbackKind {
    case pickup
    case dash
    case parry
    case hit
    case connection
    case completion
}

/// A deliberately small, self-contained touch and combat experiment.
/// All game timers use simulation time; SpriteKit actions are not used for rules.
final class GameScene: SKScene {
    var onEvent: ((SceneEvent) -> Void)?

    private enum MissionStage: String {
        case pickup, vent, guardian, anchors, socket, completed
    }

    private enum GuardianState: String {
        case idle, windup, lunge, exposed, resolved
    }

    private let worldSize = CGSize(width: 1000, height: 600)
    private let safeWorld = CGRect(x: 70, y: 95, width: 860, height: 415)
    private let spawn = CGPoint(x: 170, y: 290)
    private let pickupPosition = CGPoint(x: 270, y: 320)
    private let ventPosition = CGPoint(x: 425, y: 300)
    private let guardianHome = CGPoint(x: 680, y: 300)
    private let anchorOne = CGPoint(x: 550, y: 440)
    private let anchorTwo = CGPoint(x: 820, y: 405)
    private let socketPosition = CGPoint(x: 850, y: 175)

    private var stage: MissionStage = .pickup
    private var guardianState: GuardianState = .idle
    private var guardianClock = 0.0
    private var simulationClock = 0.0
    private var previousFrameTime: TimeInterval?
    private var inputClockOffset: TimeInterval?
    private var lastTouchSampleTime: TimeInterval?
    private var lastGestureTickTime: TimeInterval?
    private var telemetryClock = 0.0
    private var suspended = false
    private var built = false

    private var interpreter = TouchInterpreter()
    private var activeTouch: UITouch?
    private var touchOrigin: Vector2?
    private var movement = CGVector.zero
    private var playerPosition = CGPoint.zero
    private var previousPlayerPosition = CGPoint.zero
    private var dashDirection = CGVector.zero
    private var dashTime = 0.0
    private var dashContactUsed = false
    private var dashCharges = 2
    private var chargeClock = 0.0
    private var invulnerability = 0.0
    private var dwell = 0.0
    private var armorHits = 0
    private var anchorProgress = 0
    private var cargoAttached = false
    private var ventOpen = false
    private var expansionTime = 0.0

    private var guardianPosition = CGPoint.zero
    private var previousGuardianPosition = CGPoint.zero
    private var lockedTarget = CGPoint.zero
    private var lungeOrigin = CGPoint.zero
    private var lungeEnd = CGPoint.zero
    private var lungeHitUsed = false

    private let trailNode = SKShapeNode()
    private let playerNode = SKNode()
    private let cargoNode = SKShapeNode()
    private let ventNode = SKShapeNode()
    private let ventFill = SKShapeNode()
    private let guardianNode = SKNode()
    private let guardianCore = SKShapeNode()
    private let resolvedMark = SKShapeNode(circleOfRadius: 16)
    private let threatNode = SKShapeNode()
    private let expansionNode = SKShapeNode(circleOfRadius: 44)
    private let anchorOneNode = SKNode()
    private let anchorTwoNode = SKNode()
    private let tetherNode = SKShapeNode()
    private let tetherLimitNode = SKShapeNode()
    private let socketNode = SKShapeNode()
    private let socketFill = SKShapeNode()
    private let chargeOne = SKShapeNode(circleOfRadius: 10)
    private let chargeTwo = SKShapeNode(circleOfRadius: 10)
    private var trail: [CGPoint] = []
    private var trailTimes: [Double] = []

    private var reduceMotion = false
    private var assisted = false
    private var sensitivity = 1.0

    override init() {
        super.init(size: CGSize(width: 1000, height: 600))
        scaleMode = .aspectFit
        backgroundColor = UIColor(red: 0.035, green: 0.14, blue: 0.18, alpha: 1)
        isUserInteractionEnabled = true
        buildScene()
        resetState(emitObjective: false)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        size = worldSize
        scaleMode = .aspectFit
        backgroundColor = UIColor(red: 0.035, green: 0.14, blue: 0.18, alpha: 1)
        isUserInteractionEnabled = true
        buildScene()
        resetState(emitObjective: false)
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        view.isMultipleTouchEnabled = false
        emitObjective()
    }

    func configure(reduceMotion: Bool, assisted: Bool, sensitivity: Double) {
        let assistChanged = self.assisted != assisted
        let modeChanged = assistChanged || self.sensitivity != sensitivity
        self.reduceMotion = reduceMotion
        self.assisted = assisted
        self.sensitivity = max(0.5, min(1.8, sensitivity))
        if modeChanged {
            cancelInput()
            interpreter = TouchInterpreter(assisted: assisted, sensitivity: self.sensitivity)
            if assistChanged && stage == .guardian { emitObjective() }
        }
        render()
    }

    func setSuspended(_ value: Bool) {
        if suspended == value {
            if value { cancelInput() }
            return
        }
        suspended = value
        cancelInput()
        dashTime = 0
        previousFrameTime = nil
        isPaused = value
    }

    func restart() {
        isPaused = false
        suspended = false
        interpreter = TouchInterpreter(assisted: assisted, sensitivity: sensitivity)
        resetState(emitObjective: true)
    }

    private func resetState(emitObjective: Bool) {
        cancelInput()
        stage = .pickup
        guardianState = .idle
        guardianClock = 0
        simulationClock = 0
        previousFrameTime = nil
        inputClockOffset = nil
        lastTouchSampleTime = nil
        lastGestureTickTime = nil
        telemetryClock = 0
        playerPosition = spawn
        previousPlayerPosition = spawn
        guardianPosition = guardianHome
        previousGuardianPosition = guardianHome
        lockedTarget = spawn
        lungeOrigin = guardianHome
        lungeEnd = guardianHome
        lungeHitUsed = false
        dashDirection = .zero
        dashTime = 0
        dashContactUsed = false
        dashCharges = 2
        chargeClock = 0
        invulnerability = 0
        dwell = 0
        armorHits = 0
        anchorProgress = 0
        cargoAttached = false
        ventOpen = false
        expansionTime = 0
        guardianCore.path = shellPath()
        trail = [spawn]
        trailTimes = [0]
        render()
        if emitObjective { self.emitObjective() }
    }

    private func cancelInput() {
        if activeTouch != nil { apply(interpreter.cancel()) }
        activeTouch = nil
        touchOrigin = nil
        inputClockOffset = nil
        lastTouchSampleTime = nil
        lastGestureTickTime = nil
        movement = .zero
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !suspended, activeTouch == nil, let touch = touches.first,
              let input = inputPoint(for: touch) else { return }
        activeTouch = touch
        touchOrigin = input
        inputClockOffset = CACurrentMediaTime() - touch.timestamp
        lastTouchSampleTime = touch.timestamp
        lastGestureTickTime = touch.timestamp
        interpreter.begin(at: input, time: touch.timestamp)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !suspended, let touch = activeTouch, touches.contains(touch) else { return }
        guard let input = inputPoint(for: touch) else {
            cancelInput()
            return
        }
        guard touch.timestamp > (lastTouchSampleTime ?? -Double.infinity) else { return }
        lastTouchSampleTime = touch.timestamp
        apply(interpreter.move(to: input, time: touch.timestamp))
        if let origin = touchOrigin, (input - origin).length <= 8 { movement = .zero }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = activeTouch, touches.contains(touch) else { return }
        apply(interpreter.end())
        activeTouch = nil
        touchOrigin = nil
        inputClockOffset = nil
        lastTouchSampleTime = nil
        lastGestureTickTime = nil
        movement = .zero
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = activeTouch, touches.contains(touch) else { return }
        cancelInput()
    }

    /// SpriteKit's aspect-fit transform leaves UIKit view points in side/top bars.
    /// Interpreter coordinates remain screen points, with only Y flipped.
    private func inputPoint(for touch: UITouch) -> Vector2? {
        guard let view = view else { return nil }
        let point = touch.location(in: view)
        let scale = min(view.bounds.width / worldSize.width, view.bounds.height / worldSize.height)
        let visibleSize = CGSize(width: worldSize.width * scale, height: worldSize.height * scale)
        let letterbox = CGRect(
            x: (view.bounds.width - visibleSize.width) * 0.5,
            y: (view.bounds.height - visibleSize.height) * 0.5,
            width: visibleSize.width,
            height: visibleSize.height
        )
        guard letterbox.contains(point) else { return nil }
        let scenePoint = convertPoint(fromView: point)
        guard safeWorld.contains(scenePoint) else { return nil }
        return Vector2(x: Double(point.x), y: Double(view.bounds.height - point.y))
    }

    private func apply(_ actions: [TouchAction]) {
        for action in actions {
            switch action {
            case .move(let vector):
                let length = vector.length
                movement = length > 0.001
                    ? CGVector(dx: CGFloat(vector.x), dy: CGFloat(vector.y))
                    : .zero
            case .dash(let vector):
                requestDash(vector)
            case .stop:
                movement = .zero
            case .pause:
                setSuspended(true)
                onEvent?(.paused)
            }
        }
    }

    private func requestDash(_ vector: Vector2) {
        guard stage != .completed, dashCharges > 0, dashTime <= 0 else { return }
        let direction = vector.length > 0.001 ? vector.normalized : .zero
        guard direction.length > 0.001 else { return }
        dashDirection = CGVector(dx: CGFloat(direction.x), dy: CGFloat(direction.y))
        dashTime = 0.17
        dashContactUsed = false
        dashCharges -= 1
        if dashCharges == 1 { chargeClock = 0 }
        onEvent?(.feedback(.dash))
    }

    override func update(_ currentTime: TimeInterval) {
        guard !suspended, stage != .completed else { return }
        guard let previous = previousFrameTime else {
            previousFrameTime = currentTime
            return
        }
        previousFrameTime = currentTime
        let delta = max(0, min(0.033, currentTime - previous))
        if delta <= 0 { return }
        simulationClock += delta
        if let offset = inputClockOffset {
            let time = CACurrentMediaTime() - offset
            if time > (lastGestureTickTime ?? -Double.infinity),
               time > (lastTouchSampleTime ?? -Double.infinity) {
                lastGestureTickTime = time
                apply(interpreter.tick(time: time))
            }
        }
        if suspended { return }

        // A long device stall never turns into one giant movement or collision step.
        let steps = max(1, Int(ceil(delta / (1.0 / 120.0))))
        let step = delta / Double(steps)
        for _ in 0..<steps {
            if suspended { break }
            simulate(step)
        }
        render()
        if suspended { return }
        telemetryClock += delta
        if telemetryClock >= 0.25 {
            telemetryClock = 0
            onEvent?(.telemetry("\(stage.rawValue) · \(guardianState.rawValue) · zırh \(armorHits)/2 · atılma \(dashCharges)/2"))
        }
    }

    private func simulate(_ dt: Double) {
        let t = CGFloat(dt)
        invulnerability = max(0, invulnerability - dt)
        expansionTime = max(0, expansionTime - dt)
        if dashCharges < 2 {
            chargeClock += dt
            if chargeClock >= 1.05 {
                chargeClock -= 1.05
                dashCharges += 1
            }
        }

        previousPlayerPosition = playerPosition
        if dashTime > 0 {
            playerPosition.x += dashDirection.dx * 1150 * t
            playerPosition.y += dashDirection.dy * 1150 * t
            dashTime = max(0, dashTime - dt)
        } else {
            let speed: CGFloat = 235
            playerPosition.x += movement.dx * speed * t
            playerPosition.y += movement.dy * speed * t
        }
        playerPosition.x = min(max(playerPosition.x, safeWorld.minX), safeWorld.maxX)
        playerPosition.y = min(max(playerPosition.y, safeWorld.minY), safeWorld.maxY)
        if distance(playerPosition, previousPlayerPosition) > 0.1 &&
            (trail.isEmpty || distance(playerPosition, trail.last ?? playerPosition) >= 9) {
            trail.append(playerPosition)
            trailTimes.append(simulationClock)
            if trail.count > 60 {
                trail.removeFirst(trail.count - 60)
                trailTimes.removeFirst(trailTimes.count - 60)
            }
        }
        while let firstTime = trailTimes.first, simulationClock - firstTime > 3 {
            trail.removeFirst()
            trailTimes.removeFirst()
        }

        switch stage {
        case .pickup:
            if distance(playerPosition, pickupPosition) < 42 {
                cargoAttached = true
                setStage(.vent)
                onEvent?(.feedback(.pickup))
            }
        case .vent:
            if nearStill(playerPosition, ventPosition, radius: 42) {
                dwell += dt
                if dwell >= 0.8 {
                    dwell = 0
                    ventOpen = true
                    guardianState = .idle
                    guardianClock = 0
                    setStage(.guardian)
                    onEvent?(.feedback(.connection))
                }
            } else { dwell = 0 }
        case .guardian:
            simulateGuardian(dt)
        case .anchors:
            simulateAnchors()
        case .socket:
            if nearStill(playerPosition, socketPosition, radius: 42) {
                dwell += dt
                if dwell >= 0.9 {
                    cargoAttached = false
                    setStage(.completed)
                    onEvent?(.feedback(.completion))
                    onEvent?(.completed)
                    setSuspended(true)
                }
            } else { dwell = 0 }
        case .completed:
            break
        }
    }

    private func nearStill(_ point: CGPoint, _ target: CGPoint, radius: CGFloat) -> Bool {
        distance(point, target) <= radius && dashTime <= 0 &&
            hypot(movement.dx, movement.dy) < 0.1
    }

    private func simulateGuardian(_ dt: Double) {
        previousGuardianPosition = guardianPosition
        guardianClock += dt
        switch guardianState {
        case .idle:
            guardianPosition = guardianHome
            if guardianClock >= (assisted ? 0.9 : 0.65) {
                guardianClock = 0
                guardianState = .windup
                lockedTarget = playerPosition
                lungeOrigin = guardianPosition
                let direction = unit(from: lungeOrigin, to: lockedTarget)
                lungeEnd = CGPoint(
                    x: min(max(lungeOrigin.x + direction.dx * 340, safeWorld.minX), safeWorld.maxX),
                    y: min(max(lungeOrigin.y + direction.dy * 340, safeWorld.minY), safeWorld.maxY)
                )
            }
        case .windup:
            if guardianClock >= (assisted ? 1.15 : 0.72) {
                guardianClock = 0
                guardianState = .lunge
                lungeHitUsed = false
            }
        case .lunge:
            let duration = assisted ? 0.43 : 0.34
            let fraction = CGFloat(min(1, guardianClock / duration))
            guardianPosition = interpolate(lungeOrigin, lungeEnd, fraction)
            if !lungeHitUsed && sweptBodyDistance() < 43 {
                lungeHitUsed = true
                if dashTime > 0 && !dashContactUsed && isHeadOnCounter() {
                    registerArmorHit(parry: true)
                } else if invulnerability <= 0 && dashTime <= 0 {
                    takeHit()
                }
            }
            if guardianClock >= duration && guardianState == .lunge {
                guardianClock = 0
                guardianState = .exposed
            }
        case .exposed:
            if dashTime > 0 && !dashContactUsed &&
                isDashTowardSeam() &&
                segmentPointDistance(previousPlayerPosition, playerPosition, guardianPosition) < 31 {
                registerArmorHit(parry: false)
            }
            if guardianClock >= (assisted ? 2.25 : 1.4) && guardianState == .exposed {
                guardianClock = 0
                guardianState = .idle
            }
        case .resolved:
            break
        }
    }

    private func isHeadOnCounter() -> Bool {
        guard guardianClock <= (assisted ? 0.24 : 0.16) else { return false }
        let towardGuardian = unit(from: previousPlayerPosition, to: previousGuardianPosition)
        let dashDot = dashDirection.dx * towardGuardian.dx + dashDirection.dy * towardGuardian.dy
        let lungeVector = unit(from: lungeOrigin, to: lungeEnd)
        let opposed = dashDirection.dx * lungeVector.dx + dashDirection.dy * lungeVector.dy
        return dashDot > 0.35 && opposed < -0.55
    }

    private func isDashTowardSeam() -> Bool {
        let towardSeam = unit(from: previousPlayerPosition, to: guardianPosition)
        let approach = dashDirection.dx * towardSeam.dx + dashDirection.dy * towardSeam.dy
        return distance(previousPlayerPosition, guardianPosition) > 18 && approach > 0.55
    }

    private func registerArmorHit(parry: Bool) {
        guard !dashContactUsed, stage == .guardian else { return }
        dashContactUsed = true
        lungeHitUsed = true
        armorHits += 1
        guardianClock = 0
        onEvent?(.feedback(parry ? .parry : .hit))
        if armorHits >= 2 {
            guardianState = .resolved
            dashTime = 0
            setStage(.anchors)
        } else {
            guardianState = .exposed
        }
    }

    private func takeHit() {
        cancelInput()
        invulnerability = 1.2
        dashTime = 0
        movement = .zero
        let safeReturn = CGPoint(x: 480, y: 245)
        playerPosition = safeReturn
        previousPlayerPosition = safeReturn
        trail = [safeReturn]
        trailTimes = [simulationClock]
        onEvent?(.feedback(.hit))
    }

    private func simulateAnchors() {
        if anchorProgress == 0 {
            if distance(playerPosition, anchorOne) <= 37 {
                anchorProgress = 1
                emitObjective()
                onEvent?(.feedback(.connection))
            }
        } else {
            if distance(playerPosition, anchorOne) > 355 {
                anchorProgress = 0
                emitObjective()
            } else if distance(playerPosition, anchorTwo) <= 37 {
                anchorProgress = 2
                guardianState = .resolved
                guardianCore.path = CGPath(ellipseIn: CGRect(x: -39, y: -34, width: 78, height: 68), transform: nil)
                expansionTime = 0.6
                setStage(.socket)
                onEvent?(.feedback(.connection))
            }
        }
    }

    private func setStage(_ next: MissionStage) {
        guard stage != next else { return }
        stage = next
        dwell = 0
        emitObjective()
    }

    private func emitObjective() {
        let objective: String
        switch stage {
        case .pickup: objective = "Nefes kapsülüne yaklaş. Parmağını sürükleyerek ilerle."
        case .vent: objective = "Nefes'i açık halkaya götür; içinde durup bekle."
        case .guardian:
            objective = assisted
                ? "Üçgen uyarıdan sonra ilk 0,24 sn içinde karşı atıl veya açık dikişe vur: 2 isabet."
                : "Üçgen uyarıdan sonra ilk 0,16 sn içinde karşı atıl veya açık dikişe vur: 2 isabet."
        case .anchors:
            objective = anchorProgress == 0
                ? "Zırh açıldı. 1 numaralı üçgen bağlantıya git."
                : "İpliği kesikli sınırın ötesine germeden 2 numaralı kareye git."
        case .socket: objective = "Nefes'i dolu halkaya taşı ve içinde bekle."
        case .completed: objective = "Nefes teslim edildi. Geçit yeniden soluyor."
        }
        onEvent?(.objective(objective))
    }

    private func buildScene() {
        guard !built else { return }
        built = true
        let ink = UIColor(red: 0.035, green: 0.14, blue: 0.18, alpha: 1)
        let teal = UIColor(red: 0.17, green: 0.48, blue: 0.48, alpha: 1)
        let coral = UIColor(red: 0.86, green: 0.43, blue: 0.40, alpha: 1)
        let gold = UIColor(red: 0.99, green: 0.79, blue: 0.39, alpha: 1)
        let pearl = UIColor(red: 0.96, green: 0.97, blue: 0.91, alpha: 1)

        let arena = SKShapeNode(rect: safeWorld, cornerRadius: 86)
        arena.fillColor = UIColor(red: 0.07, green: 0.24, blue: 0.28, alpha: 1)
        arena.strokeColor = teal
        arena.lineWidth = 5
        arena.zPosition = -20
        addChild(arena)
        for (index, position) in [CGPoint(x: 110, y: 495), CGPoint(x: 245, y: 505),
                                  CGPoint(x: 775, y: 97), CGPoint(x: 930, y: 360)].enumerated() {
            let membrane = SKShapeNode(ellipseOf: CGSize(width: index.isMultiple(of: 2) ? 215 : 150,
                                                          height: index.isMultiple(of: 2) ? 88 : 125))
            membrane.position = position
            membrane.zRotation = index.isMultiple(of: 2) ? 0.3 : -0.35
            membrane.fillColor = coral.withAlphaComponent(0.25)
            membrane.strokeColor = coral.withAlphaComponent(0.55)
            membrane.lineWidth = 3
            membrane.zPosition = -15
            addChild(membrane)
        }

        trailNode.strokeColor = gold.withAlphaComponent(0.75)
        trailNode.lineWidth = 3
        trailNode.lineCap = .round
        trailNode.zPosition = 0
        addChild(trailNode)

        cargoNode.path = diamondPath(radius: 16)
        cargoNode.fillColor = pearl
        cargoNode.strokeColor = gold
        cargoNode.lineWidth = 4
        cargoNode.zPosition = 8
        addChild(cargoNode)

        ventNode.path = openRingPath(radius: 37)
        ventNode.position = ventPosition
        ventNode.strokeColor = gold
        ventNode.lineWidth = 6
        ventNode.zPosition = 2
        addChild(ventNode)
        ventFill.path = CGPath(ellipseIn: CGRect(x: -29, y: -29, width: 58, height: 58), transform: nil)
        ventFill.position = ventPosition
        ventFill.fillColor = teal.withAlphaComponent(0.5)
        ventFill.strokeColor = .clear
        ventFill.zPosition = 1
        addChild(ventFill)

        guardianCore.path = shellPath()
        guardianCore.fillColor = coral
        guardianCore.strokeColor = pearl
        guardianCore.lineWidth = 5
        guardianNode.addChild(guardianCore)
        let seam = SKShapeNode(path: diamondPath(radius: 12))
        seam.fillColor = ink
        seam.strokeColor = pearl
        seam.lineWidth = 3
        seam.position = CGPoint(x: 0, y: 7)
        seam.name = "seam"
        guardianNode.addChild(seam)
        resolvedMark.fillColor = ink
        resolvedMark.strokeColor = gold
        resolvedMark.lineWidth = 4
        resolvedMark.isHidden = true
        guardianNode.addChild(resolvedMark)
        guardianNode.zPosition = 6
        addChild(guardianNode)

        expansionNode.strokeColor = gold
        expansionNode.fillColor = .clear
        expansionNode.lineWidth = 6
        expansionNode.zPosition = 5
        addChild(expansionNode)

        threatNode.strokeColor = pearl
        threatNode.lineWidth = 5
        threatNode.lineCap = .round
        threatNode.zPosition = 4
        addChild(threatNode)

        buildAnchor(anchorOneNode, triangle: true, number: "1", color: gold)
        buildAnchor(anchorTwoNode, triangle: false, number: "2", color: gold)
        anchorOneNode.position = anchorOne
        anchorTwoNode.position = anchorTwo
        anchorOneNode.zPosition = 3
        anchorTwoNode.zPosition = 3
        addChild(anchorOneNode)
        addChild(anchorTwoNode)
        tetherNode.strokeColor = gold
        tetherNode.lineWidth = 5
        tetherNode.zPosition = 1
        addChild(tetherNode)
        let limitPath = CGMutablePath()
        for index in 0..<32 {
            let start = CGFloat(index) * .pi / 16
            limitPath.addArc(center: .zero, radius: 355,
                             startAngle: start, endAngle: start + .pi / 32,
                             clockwise: false)
        }
        tetherLimitNode.path = limitPath
        tetherLimitNode.position = anchorOne
        tetherLimitNode.strokeColor = gold.withAlphaComponent(0.42)
        tetherLimitNode.lineWidth = 3
        tetherLimitNode.zPosition = 1
        addChild(tetherLimitNode)

        socketNode.path = CGPath(ellipseIn: CGRect(x: -39, y: -39, width: 78, height: 78), transform: nil)
        socketNode.position = socketPosition
        socketNode.strokeColor = pearl
        socketNode.lineWidth = 6
        socketNode.fillColor = ink
        socketNode.zPosition = 2
        addChild(socketNode)
        socketFill.path = CGPath(ellipseIn: CGRect(x: -30, y: -30, width: 60, height: 60), transform: nil)
        socketFill.position = socketPosition
        socketFill.fillColor = gold.withAlphaComponent(0.45)
        socketFill.strokeColor = .clear
        socketFill.zPosition = 3
        addChild(socketFill)

        let leftWing = SKShapeNode(ellipseOf: CGSize(width: 26, height: 14))
        leftWing.position = CGPoint(x: -20, y: 12)
        leftWing.zRotation = 0.55
        leftWing.fillColor = pearl.withAlphaComponent(0.7)
        leftWing.strokeColor = teal
        leftWing.lineWidth = 2
        playerNode.addChild(leftWing)
        let rightWing = SKShapeNode(ellipseOf: CGSize(width: 26, height: 14))
        rightWing.position = CGPoint(x: 20, y: 12)
        rightWing.zRotation = -0.55
        rightWing.fillColor = pearl.withAlphaComponent(0.7)
        rightWing.strokeColor = teal
        rightWing.lineWidth = 2
        playerNode.addChild(rightWing)
        let body = SKShapeNode(ellipseOf: CGSize(width: 43, height: 48))
        body.fillColor = pearl
        body.strokeColor = gold
        body.lineWidth = 3
        playerNode.addChild(body)
        let face = SKShapeNode(ellipseOf: CGSize(width: 19, height: 15))
        face.position = CGPoint(x: 0, y: 5)
        face.fillColor = ink
        face.strokeColor = .clear
        playerNode.addChild(face)
        for dx in [-4.0, 4.0] {
            let eye = SKShapeNode(circleOfRadius: 1.6)
            eye.position = CGPoint(x: CGFloat(dx), y: 7)
            eye.fillColor = pearl
            eye.strokeColor = .clear
            playerNode.addChild(eye)
        }
        playerNode.zPosition = 10
        addChild(playerNode)

        for (index, ring) in [chargeOne, chargeTwo].enumerated() {
            ring.position = CGPoint(x: CGFloat(index == 0 ? -13 : 13), y: -37)
            ring.fillColor = ink
            ring.strokeColor = gold
            ring.lineWidth = 3
            playerNode.addChild(ring)
        }
    }

    private func buildAnchor(_ node: SKNode, triangle: Bool, number: String, color: UIColor) {
        let outline = SKShapeNode(path: triangle ? trianglePath(radius: 32) : squarePath(radius: 29))
        outline.fillColor = UIColor(red: 0.04, green: 0.19, blue: 0.22, alpha: 1)
        outline.strokeColor = color
        outline.lineWidth = 6
        node.addChild(outline)
        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.text = number
        label.fontSize = 29
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        node.addChild(label)
    }

    private func render() {
        guard built else { return }
        let gold = UIColor(red: 0.99, green: 0.79, blue: 0.39, alpha: 1)
        let pearl = UIColor(red: 0.96, green: 0.97, blue: 0.91, alpha: 1)
        let coral = UIColor(red: 0.86, green: 0.43, blue: 0.40, alpha: 1)
        playerNode.position = playerPosition
        playerNode.alpha = invulnerability > 0 && !reduceMotion ? 0.6 : 1
        chargeOne.strokeColor = dashCharges >= 1 ? gold : .gray
        chargeTwo.strokeColor = dashCharges >= 2 ? gold : .gray

        let ribbon = CGMutablePath()
        if let first = trail.first {
            ribbon.move(to: first)
            for point in trail.dropFirst() { ribbon.addLine(to: point) }
            ribbon.addLine(to: playerPosition)
        }
        trailNode.path = ribbon
        cargoNode.isHidden = stage == .completed
        cargoNode.position = cargoAttached
            ? CGPoint(x: playerPosition.x - 30, y: playerPosition.y - 26)
            : pickupPosition
        ventNode.isHidden = stage == .pickup
        ventFill.isHidden = !ventOpen && stage != .vent
        ventFill.xScale = ventOpen ? 1.5 : CGFloat(max(0.12, dwell / 0.8))
        ventFill.yScale = ventFill.xScale
        guardianNode.isHidden = stage == .pickup || stage == .vent
        guardianNode.position = guardianPosition
        guardianCore.fillColor = guardianState == .resolved ? UIColor(red: 0.25, green: 0.56, blue: 0.51, alpha: 1) : coral
        guardianCore.strokeColor = guardianState == .exposed ? gold : pearl
        let seam = guardianNode.childNode(withName: "seam")
        seam?.isHidden = guardianState == .resolved
        seam?.xScale = guardianState == .exposed ? 1.6 : 1
        resolvedMark.isHidden = guardianState != .resolved
        expansionNode.isHidden = reduceMotion || expansionTime <= 0
        if !expansionNode.isHidden {
            expansionNode.position = guardianPosition
            expansionNode.setScale(CGFloat(1 + (0.6 - expansionTime) * 2.2))
            expansionNode.alpha = CGFloat(expansionTime / 0.6)
        }
        threatNode.isHidden = guardianState != .windup || stage != .guardian
        if !threatNode.isHidden {
            let direction = unit(from: lungeOrigin, to: lungeEnd)
            let perpendicular = CGVector(dx: -direction.dy, dy: direction.dx)
            let path = CGMutablePath()
            path.move(to: lungeOrigin)
            path.addLine(to: lungeEnd)
            let arrowBase = CGPoint(x: lungeEnd.x - direction.dx * 29,
                                    y: lungeEnd.y - direction.dy * 29)
            path.move(to: CGPoint(x: arrowBase.x + perpendicular.dx * 20,
                                  y: arrowBase.y + perpendicular.dy * 20))
            path.addLine(to: lungeEnd)
            path.addLine(to: CGPoint(x: arrowBase.x - perpendicular.dx * 20,
                                     y: arrowBase.y - perpendicular.dy * 20))
            threatNode.path = path
        }
        anchorOneNode.isHidden = stage != .anchors
        anchorTwoNode.isHidden = stage != .anchors
        anchorTwoNode.alpha = anchorProgress == 0 ? 0.42 : 1
        if stage == .anchors && anchorProgress == 1 {
            let path = CGMutablePath()
            path.move(to: anchorOne)
            path.addLine(to: playerPosition)
            tetherNode.path = path
            tetherNode.lineWidth = distance(anchorOne, playerPosition) > 290 ? 8 : 5
        } else { tetherNode.path = nil }
        tetherLimitNode.isHidden = stage != .anchors || anchorProgress != 1
        socketNode.isHidden = stage != .socket && stage != .completed
        socketFill.isHidden = stage != .socket && stage != .completed
        socketFill.xScale = stage == .completed ? 1.2 : CGFloat(max(0.1, dwell / 0.9))
        socketFill.yScale = socketFill.xScale
        if reduceMotion {
            guardianNode.zRotation = 0
            cargoNode.zRotation = 0
        } else {
            guardianNode.zRotation = guardianState == .windup ? CGFloat(sin(simulationClock * 9) * 0.035) : 0
            cargoNode.zRotation = CGFloat(sin(simulationClock * 2.8) * 0.1)
        }
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        hypot(a.x - b.x, a.y - b.y)
    }

    private func unit(from a: CGPoint, to b: CGPoint) -> CGVector {
        let length = max(0.001, distance(a, b))
        return CGVector(dx: (b.x - a.x) / length, dy: (b.y - a.y) / length)
    }

    private func interpolate(_ a: CGPoint, _ b: CGPoint, _ t: CGFloat) -> CGPoint {
        CGPoint(x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t)
    }

    private func segmentPointDistance(_ a: CGPoint, _ b: CGPoint, _ p: CGPoint) -> CGFloat {
        let dx = b.x - a.x
        let dy = b.y - a.y
        let lengthSquared = dx * dx + dy * dy
        if lengthSquared < 0.0001 { return distance(a, p) }
        let t = max(0, min(1, ((p.x - a.x) * dx + (p.y - a.y) * dy) / lengthSquared))
        return distance(interpolate(a, b, t), p)
    }

    /// Relative swept motion checks the two moving bodies at matching times.
    private func sweptBodyDistance() -> CGFloat {
        let relativeStart = CGPoint(x: previousPlayerPosition.x - previousGuardianPosition.x,
                                    y: previousPlayerPosition.y - previousGuardianPosition.y)
        let relativeEnd = CGPoint(x: playerPosition.x - guardianPosition.x,
                                  y: playerPosition.y - guardianPosition.y)
        return segmentPointDistance(relativeStart, relativeEnd, .zero)
    }

    private func diamondPath(radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: radius))
        path.addLine(to: CGPoint(x: radius, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -radius))
        path.addLine(to: CGPoint(x: -radius, y: 0))
        path.closeSubpath()
        return path
    }

    private func trianglePath(radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: radius))
        path.addLine(to: CGPoint(x: radius, y: -radius * 0.7))
        path.addLine(to: CGPoint(x: -radius, y: -radius * 0.7))
        path.closeSubpath()
        return path
    }

    private func squarePath(radius: CGFloat) -> CGPath {
        CGPath(rect: CGRect(x: -radius, y: -radius, width: 2 * radius, height: 2 * radius), transform: nil)
    }

    private func openRingPath(radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.addArc(center: .zero, radius: radius, startAngle: 0.55, endAngle: 2 * .pi - 0.55,
                    clockwise: false)
        return path
    }

    private func shellPath() -> CGPath {
        let path = CGMutablePath()
        let points: [CGPoint] = [
            CGPoint(x: -41, y: -13), CGPoint(x: -49, y: 18), CGPoint(x: -25, y: 23),
            CGPoint(x: -18, y: 43), CGPoint(x: 0, y: 31), CGPoint(x: 20, y: 43),
            CGPoint(x: 28, y: 22), CGPoint(x: 50, y: 17), CGPoint(x: 41, y: -17),
            CGPoint(x: 16, y: -35), CGPoint(x: -18, y: -35)
        ]
        if let first = points.first {
            path.move(to: first)
            for point in points.dropFirst() { path.addLine(to: point) }
            path.closeSubpath()
        }
        return path
    }
}
