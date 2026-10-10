import SpriteKit
import SwiftUI

@MainActor
struct GardenView: View {
    @StateObject private var session = GameSession()
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @AccessibilityFocusState private var panelFocused: Bool
    private let gold = Color(red: 0.94, green: 0.82, blue: 0.55)

    var body: some View {
        ZStack {
            Color(red: 0.035, green: 0.095, blue: 0.115).ignoresSafeArea()
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Text("SEROTONIN")
                        .font(.system(.caption, design: .serif).weight(.medium))
                        .tracking(3)
                        .foregroundStyle(gold)
                        .accessibilityHidden(true)
                    Text(session.objective)
                        .font(.callout)
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityLabel("Görev: \(session.objective)")
                    if session.showPause && session.presentation == .playing {
                        Button(action: session.pause) {
                            Image(systemName: "pause")
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .accessibilityLabel("Oyunu duraklat ve ayarları aç")
                        .keyboardShortcut(.escape, modifiers: [])
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 4)

                SpriteView(scene: session.scene,
                           isPaused: session.presentation != .playing,
                           preferredFramesPerSecond: 60)
                    .allowsHitTesting(session.presentation == .playing)
                    .accessibilityHidden(true)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if session.showDiagnostics {
                    Text(session.telemetry.isEmpty ? "Tanılama: oyun başlayınca güncellenir." : session.telemetry)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(gold)
                        .padding(.horizontal)
                        .padding(.bottom, 4)
                        .allowsHitTesting(false)
                }
            }

            if session.presentation != .playing {
                Color.black.opacity(0.65).ignoresSafeArea()
                ScrollView {
                    panel
                        .frame(maxWidth: 580)
                        .frame(maxWidth: .infinity)
                        .padding(22)
                }
                .background(.ultraThinMaterial)
            }
        }
        .tint(gold)
        .onAppear { session.setSystemReduceMotion(systemReduceMotion) }
        .onChange(of: systemReduceMotion) { _, enabled in
            session.setSystemReduceMotion(enabled)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { session.applicationBecameInactive() }
        }
        .onChange(of: session.presentation) { _, presentation in
            panelFocused = presentation != .playing
        }
        .statusBarHidden()
    }

    @ViewBuilder private var panel: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(panelTitle)
                .font(.system(.largeTitle, design: .serif))
                .foregroundStyle(gold)
                .accessibilityAddTraits(.isHeader)
                .accessibilityFocused($panelFocused)

            if session.presentation == .completed {
                Text("Bir pencere açıldı. Deniz derin bir nefes aldı.")
                    .font(.title3)
                Text("Nefes yerine ulaştı. Bu kısa deneme, İlmek'in hareketini ve ilk bağını sınamak için hazırlandı.")
                    .foregroundStyle(.secondary)
                actionButton("Yeniden oyna", action: session.start)
            } else {
                if session.presentation == .introduction {
                    Text("Nefesin Eşiği")
                        .font(.title3)
                    Text("Küçük bir kuryenin ilk bağı. Nefes'i al, açık halkayı uyandır ve muhafızın arkasındaki yolu aç.")
                } else {
                    Text("İlmek burada bekliyor. Hazır olduğunda devam et.")
                }

                VStack(alignment: .leading, spacing: 8) {
                    Label("Sürükleyerek hareket et.", systemImage: "hand.draw")
                    Label(session.assisted
                          ? "Yönü belirgin biçimde çekip sabit tut: kısa hazırlıktan sonra atıl."
                          : "Parmağını yeniden koyup kısa ve hızlı savur: atıl.",
                          systemImage: "arrow.up.right")
                    Label("Durduğunda bir noktaya basılı tutarak duraklat.", systemImage: "pause.circle")
                }
                .font(.callout)
                .foregroundStyle(.white.opacity(0.85))

                actionButton(session.presentation == .introduction ? "İlk nefesi taşı" : "Devam et") {
                    if session.presentation == .introduction { session.start() }
                    else { session.resume() }
                }

                DisclosureGroup("Kontrol ve erişilebilirlik") {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Yumuşak kontrol", isOn: $session.assisted)
                        Text("Hızlı savuruş yerine belirgin bir yöne çekip sabit tutarak atıl. Muhafız daha uzun hazırlık ve açıklık süreleri verir.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Toggle("Hareketi azalt", isOn: $session.reduceMotion)
                        Toggle("Dokunsal geri bildirim", isOn: $session.hapticsEnabled)
                        Toggle("Duraklatma simgesini göster", isOn: $session.showPause)
                        Text("Simgeyi gizlersen dururken basılı tutarak menüyü açabilirsin.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading) {
                            Text("Hareket hassasiyeti")
                            Slider(value: $session.sensitivity, in: 0.6...1.5, step: 0.1)
                                .accessibilityLabel("Hareket hassasiyeti")
                                .accessibilityValue(String(format: "%.1f", session.sensitivity))
                        }
                        Toggle("Prototip tanılaması", isOn: $session.showDiagnostics)
                    }
                    .padding(.top, 12)
                }
                if session.presentation == .paused {
                    Button("Denemeyi baştan başlat", action: session.start)
                        .frame(minHeight: 44)
                }
                Text("Kontrol prototipi · iPhone · v0.1")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var panelTitle: String {
        switch session.presentation {
        case .introduction: return "Serotonin"
        case .paused: return "Küçük bir mola."
        case .completed: return "Biraz daha ferah."
        case .playing: return ""
        }
    }

    private func actionButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).fontWeight(.semibold)
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.borderedProminent)
        .foregroundStyle(Color(red: 0.055, green: 0.12, blue: 0.13))
    }
}
