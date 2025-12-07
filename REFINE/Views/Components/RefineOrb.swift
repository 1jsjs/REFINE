import SwiftUI

struct RefineOrb: View {
    var tint: Color?          // nil이면 완전 투명(로딩 시작 상태)
    var fillProgress: CGFloat // 0.0 ~ 1.0
    var isShimmering: Bool    // 분석 중 흐름
    var isPolished: Bool      // 마무리 광택(스파클)

    @State private var breathe = false
    @State private var shimmer = false
    @State private var sparkle = false

    var body: some View {
        let size: CGFloat = 160

        ZStack {
            // Base glass
            Circle()
                .fill(.ultraThinMaterial)
                .overlay(Circle().strokeBorder(.white.opacity(0.18), lineWidth: 1))
                .shadow(color: .black.opacity(0.35), radius: 18, y: 10)

            // Fill color from bottom
            if let tint {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                tint.opacity(0.75),
                                tint.opacity(0.35),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: size * 0.55
                        )
                    )
                    .overlay(Circle().fill(tint.opacity(0.10)))
                    .mask(
                        Rectangle()
                            .frame(height: size * max(0, min(1, fillProgress)))
                            .frame(maxHeight: .infinity, alignment: .bottom)
                    )
                    .animation(.easeInOut(duration: 0.8), value: fillProgress)
            }

            // Highlight
            Circle()
                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
                .overlay(
                    Ellipse()
                        .fill(.white.opacity(0.22))
                        .blur(radius: 10)
                        .frame(width: size * 0.62, height: size * 0.28)
                        .offset(x: -16, y: -36)
                        .opacity(breathe ? 0.85 : 0.55)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: breathe)
                )

            // Shimmer flow
            if isShimmering {
                RoundedRectangle(cornerRadius: 999)
                    .fill(.white.opacity(0.10))
                    .blur(radius: 8)
                    .frame(width: size * 0.55, height: size * 0.12)
                    .rotationEffect(.degrees(-18))
                    .offset(x: shimmer ? 60 : -60, y: -10)
                    .mask(Circle().frame(width: size, height: size))
                    .animation(.linear(duration: 1.0).repeatForever(autoreverses: false), value: shimmer)
            }

            // Polish: outer glow + sparkle
            if isPolished, let tint {
                Circle()
                    .strokeBorder(tint.opacity(0.55), lineWidth: 2)
                    .blur(radius: 2)
                    .transition(.opacity)

                // simple sparkle: tiny star-ish cross
                ZStack {
                    Capsule().fill(.white.opacity(0.85)).frame(width: 18, height: 2)
                    Capsule().fill(.white.opacity(0.85)).frame(width: 2, height: 18)
                }
                .blur(radius: 0.2)
                .scaleEffect(sparkle ? 1.0 : 0.2)
                .opacity(sparkle ? 1.0 : 0.0)
                .offset(x: 34, y: -44)
                .onAppear { sparkle = true }
                .animation(.easeOut(duration: 0.28), value: sparkle)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            breathe = true
            if isShimmering { shimmer = true }
        }
        .onChange(of: isShimmering) { _, newValue in
            shimmer = newValue
        }
    }
}
