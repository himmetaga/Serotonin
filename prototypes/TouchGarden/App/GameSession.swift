import Combine
import SwiftUI
import UIKit

/// Owns exactly one scene across SwiftUI body updates.
@MainActor
final class GameSession: ObservableObject {
    enum Presentation: Equatable { case introduction, playing, paused, completed }

    let scene = GameScene()
    @Published private(set) var presentation: Presentation = .introduction
    @Published private(set) var objective = "İlmek'in ilk yolculuğu."
    @Published private(set) var telemetry = ""
    @Published var assisted = false { didSet { configureScene() } }
    @Published var reduceMotion = false { didSet { configureScene() } }
    @Published var sensitivity = 1.0 { didSet { configureScene() } }
    @Published var hapticsEnabled = true
    @Published var showPause = true
    @Published var showDiagnostics = false
    private var systemReduceMotion = false
    private let haptics = HapticFeedback()

    init() {
        scene.onEvent = { [weak self] event in self?.receive(event) }
        scene.setSuspended(true)
        configureScene()
    }

    func start() {
        scene.restart()
        configureScene()
        presentation = .playing
        scene.setSuspended(false)
        haptics.prepare()
    }

    func pause() {
        guard presentation == .playing else { return }
        scene.setSuspended(true)
        presentation = .paused
    }

    func resume() {
        guard presentation == .paused else { return }
        configureScene()
        presentation = .playing
        scene.setSuspended(false)
        haptics.prepare()
    }

    func applicationBecameInactive() { pause() }

    func setSystemReduceMotion(_ enabled: Bool) {
        systemReduceMotion = enabled
        configureScene()
    }

    private func configureScene() {
        scene.configure(reduceMotion: reduceMotion || systemReduceMotion,
                        assisted: assisted, sensitivity: sensitivity)
    }

    private func receive(_ event: SceneEvent) {
        switch event {
        case .objective(let text): objective = text
        case .telemetry(let text):
            if showDiagnostics { telemetry = text }
        case .feedback(let kind):
            if hapticsEnabled { haptics.play(kind) }
        case .paused: pause()
        case .completed:
            scene.setSuspended(true)
            presentation = .completed
        }
    }
}

/// Small event feedback for the control experiment; final audio/haptic art is separate.
@MainActor
private final class HapticFeedback {
    private let soft = UIImpactFeedbackGenerator(style: .soft)
    private let rigid = UIImpactFeedbackGenerator(style: .rigid)
    private let notification = UINotificationFeedbackGenerator()

    func prepare() { soft.prepare(); rigid.prepare(); notification.prepare() }

    func play(_ kind: FeedbackKind) {
        switch kind {
        case .pickup: soft.impactOccurred(intensity: 0.45)
        case .dash: soft.impactOccurred(intensity: 0.25)
        case .parry: rigid.impactOccurred(intensity: 0.7)
        case .hit: rigid.impactOccurred(intensity: 0.4)
        case .connection: soft.impactOccurred(intensity: 0.7)
        case .completion: notification.notificationOccurred(.success)
        }
    }
}
