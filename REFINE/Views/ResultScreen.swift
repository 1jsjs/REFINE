import SwiftUI

struct ResultScreen: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showCopyAlert: Bool = false
    @State private var showSaveAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        let palette = themeManager.paletteFor(themeManager.currentTone)

        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header with Back Button
                    HStack {
                        Button(action: {
                            appState.handleReset()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .medium))

                                Text("새 기록")
                                    .font(.system(size: 17))
                            }
                            .foregroundColor(palette.accent)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, max(60, geometry.safeAreaInsets.top + 20))
                    .padding(.bottom, 48)

                // Keywords - Large, Bold with tone color
                if !appState.analysisKeywords.isEmpty {
                    FlowLayout(spacing: 8) {
                        ForEach(appState.analysisKeywords, id: \.self) { keyword in
                            Text(keyword)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(palette.accent)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(palette.chipBg)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 999)
                                        .stroke(palette.accent.opacity(0.35), lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 999))
                                .fixedSize()
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                } else {
                    Text("분석 중...")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 48)
                }

                // Summary Card
                if !appState.analysisSummary.isEmpty {
                    Text(appState.analysisSummary)
                        .font(.system(size: 15))
                        .foregroundColor(themeManager.theme == .dark ? .white : Color(red: 28/255, green: 28/255, blue: 30/255))
                        .lineSpacing(4)
                        .padding(24)
                        .background(themeManager.theme == .dark ? Color.darkElevated : Color.systemGray6)
                        .cornerRadius(16)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                }

                // One-Liner Card
                if !appState.analysisOneLiner.isEmpty {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("자소서용 한 줄")
                                .font(.system(size: 13))
                                .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)

                            Text(appState.analysisOneLiner)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(themeManager.theme == .dark ? .white : .black)
                                .lineSpacing(4)
                        }

                        Spacer()

                        Button(action: {
                            UIPasteboard.general.string = appState.analysisOneLiner
                            alertMessage = "자소서용 한 줄이 복사되었습니다"
                            showCopyAlert = true
                        }) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 20))
                                .foregroundColor(palette.accent)
                                .frame(width: 40, height: 40)
                                .background(palette.chipBg)
                                .clipShape(Circle())
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(palette.accent, lineWidth: 2)
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }

                // Action Buttons
                HStack(spacing: 12) {
                    // Save Image Button
                    Button(action: {
                        alertMessage = "갤러리에 이미지가 저장되었습니다"
                        showSaveAlert = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.system(size: 20))

                            Text("이미지 저장")
                                .font(.system(size: 17))
                        }
                        .foregroundColor(.systemBlue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.systemGray5, lineWidth: 1)
                        )
                    }

                    // Copy Text Button
                    Button(action: {
                        let copyText = "\(appState.analysisKeywords.joined(separator: " "))\n\n\(appState.analysisSummary)"
                        UIPasteboard.general.string = copyText
                        alertMessage = "클립보드에 텍스트가 복사되었습니다"
                        showCopyAlert = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 20))

                            Text("텍스트 복사")
                                .font(.system(size: 17))
                        }
                        .foregroundColor(palette.accent)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.systemGray5, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, max(40, geometry.safeAreaInsets.bottom + 20))
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(themeManager.theme == .dark ? Color.darkBackground : .white)
        .alert("완료", isPresented: $showCopyAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .alert("완료", isPresented: $showSaveAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
}

// FlowLayout for wrapping keyword tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}
