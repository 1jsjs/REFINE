import SwiftUI

struct AnalysisScreen: View {
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var dotOpacity: Double = 0.3

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()

                // Geometric Shape - Minimalist prism/gem
            ZStack {
                // Outer pulsing glow
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.systemBlue.opacity(0.1))
                    .frame(width: 128, height: 128)
                    .scaleEffect(pulseScale)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true)
                        ) {
                            pulseScale = 1.15
                        }
                    }

                // Inner geometric shape
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.systemBlue, lineWidth: 2)
                    .frame(width: 96, height: 96)
                    .rotationEffect(.degrees(rotationAngle))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.systemBlue, lineWidth: 2)
                            .frame(width: 32, height: 32)
                    )
                    .onAppear {
                        withAnimation(
                            .linear(duration: 8.0)
                            .repeatForever(autoreverses: false)
                        ) {
                            rotationAngle = 360
                        }
                    }

                // Center dot
                Circle()
                    .fill(Color.systemBlue)
                    .frame(width: 8, height: 8)
                    .opacity(dotOpacity)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true)
                        ) {
                            dotOpacity = 1.0
                        }
                    }
            }
            .frame(width: 128, height: 128)
            .padding(.bottom, 32)

            // Loading Text
            Text("당신의 기록에서 핵심 가치를 발견하고 있습니다...")
                .font(.system(size: 15, design: .serif))
                .foregroundColor(.systemGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
    }
}
