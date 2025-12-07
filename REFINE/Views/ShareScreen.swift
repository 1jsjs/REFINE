import SwiftUI

enum CardColor: String, CaseIterable {
    case white = "화이트"
    case blue = "블루"
    case purple = "퍼플"
    case gradient = "그라데이션"

    var backgroundStyle: AnyShapeStyle {
        switch self {
        case .white:
            return AnyShapeStyle(Color.white)
        case .blue:
            return AnyShapeStyle(Color.systemBlue)
        case .purple:
            return AnyShapeStyle(Color.systemPurple)
        case .gradient:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [.systemBlue, .systemPurple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }

    var textColor: Color {
        self == .white ? .black : .white
    }
}

struct ShareScreen: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedColor: CardColor = .white
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var shareImage: UIImage?
    @State private var showShareSheet: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack {
                        Button(action: {
                            appState.handleBack()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .medium))

                                Text("대시보드")
                                    .font(.system(size: 17))
                            }
                            .foregroundColor(.systemBlue)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, max(60, geometry.safeAreaInsets.top + 20))
                    .padding(.bottom, 24)

                Text("공유하기")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(themeManager.theme == .dark ? .white : .black)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)

                Text("결과를 이미지로 만들어 공유하세요")
                    .font(.system(size: 17))
                    .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)

                // Preview Card
                ZStack(alignment: .topTrailing) {
                    ShareCardView(
                        keywords: appState.analysisKeywords,
                        oneLiner: appState.analysisOneLiner,
                        selectedColor: selectedColor
                    )
                    .aspectRatio(9/16, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)

                    // Old card view kept for reference
                    /*VStack(alignment: .leading, spacing: 0) {
                        // Logo
                        Text("REFINE")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(selectedColor.textColor.opacity(0.9))
                            .padding(.bottom, 100)

                        // Content
                        VStack(alignment: .leading, spacing: 24) {
                            Text(appState.analysisKeywords.joined(separator: " "))
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(selectedColor.textColor)

                            Text(appState.analysisOneLiner)
                                .font(.system(size: 20))
                                .foregroundColor(selectedColor.textColor.opacity(0.9))
                                .lineSpacing(6)

                            Text("기록에서 발견한 나의 핵심 가치")
                                .font(.system(size: 15))
                                .foregroundColor(selectedColor.textColor.opacity(0.7))
                        }
                        .padding(.bottom, 100)

                        // Footer
                        Text("2024.11.17 - 11.23")
                            .font(.system(size: 13))
                            .foregroundColor(selectedColor.textColor.opacity(0.6))
                    }
                    .padding(32)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(9/16, contentMode: .fit)
                    .background(selectedColor.backgroundStyle)
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)*/

                    // Size indicator
                    Text("Instagram Story")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(themeManager.theme == .dark ? .black : .white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(themeManager.theme == .dark ? .white : .black)
                        .clipShape(Capsule())
                        .offset(x: -12, y: -12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)

                // Color Options
                Text("배경 색상")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(themeManager.theme == .dark ? .white : .black)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)

                HStack(spacing: 12) {
                    ForEach(CardColor.allCases, id: \.self) { color in
                        ColorOption(color: color, isSelected: selectedColor == color) {
                            selectedColor = color
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)

                // Action Buttons
                VStack(spacing: 12) {
                    // Download Button
                    Button(action: {
                        if let image = captureShareCard() {
                            saveImageToGallery(image)
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 20))

                            Text("이미지 저장")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.systemBlue)
                        .cornerRadius(16)
                    }

                    // Share Options
                    HStack(spacing: 12) {
                        ShareButton(platform: "Instagram", icon: "camera.fill", color: Color(red: 225/255, green: 48/255, blue: 108/255), theme: themeManager.theme) {
                            if let image = captureShareCard() {
                                shareToInstagram(image: image)
                            }
                        }

                        ShareButton(platform: "X", icon: "at", color: Color(red: 29/255, green: 161/255, blue: 242/255), theme: themeManager.theme) {
                            if let image = captureShareCard() {
                                shareImage = image
                                showShareSheet = true
                            }
                        }
                    }

                    // General Share
                    Button(action: {
                        if let image = captureShareCard() {
                            shareImage = image
                            showShareSheet = true
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 20))
                                .foregroundColor(.systemBlue)

                            Text("다른 방법으로 공유")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(themeManager.theme == .dark ? .white : .black)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(themeManager.theme == .dark ? Color.darkElevated : Color.systemGray6)
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, max(40, geometry.safeAreaInsets.bottom + 20))
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(themeManager.theme == .dark ? Color.darkBackground : .white)
        .alert("완료", isPresented: $showAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = shareImage {
                ActivityViewController(activityItems: [image])
            }
        }
    }

    // Capture share card as image
    func captureShareCard() -> UIImage? {
        let card = ShareCardView(
            keywords: appState.analysisKeywords,
            oneLiner: appState.analysisOneLiner,
            selectedColor: selectedColor
        )

        let controller = UIHostingController(rootView: card)
        let view = controller.view

        let targetSize = CGSize(width: 1080, height: 1920) // Instagram Story size
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }

    func saveImageToGallery(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        alertMessage = "이미지가 갤러리에 저장되었습니다"
        showAlert = true
    }

    func shareToInstagram(image: UIImage) {
        guard let instagramURL = URL(string: "instagram-stories://share"),
              UIApplication.shared.canOpenURL(instagramURL) else {
            alertMessage = "Instagram 앱이 설치되어 있지 않습니다"
            showAlert = true
            return
        }

        guard let imageData = image.pngData() else {
            alertMessage = "이미지 처리 중 오류가 발생했습니다"
            showAlert = true
            return
        }

        let pasteboardItems: [[String: Any]] = [
            [
                "com.instagram.sharedSticker.stickerImage": imageData,
                "com.instagram.sharedSticker.backgroundTopColor": "#6558F5",
                "com.instagram.sharedSticker.backgroundBottomColor": "#E74697"
            ]
        ]

        let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [
            .expirationDate: Date().addingTimeInterval(60 * 5)
        ]

        UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
        UIApplication.shared.open(instagramURL)
    }
}

// Share card view that can be rendered to image
struct ShareCardView: View {
    let keywords: [String]
    let oneLiner: String
    let selectedColor: CardColor

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Logo
            Text("REFINE")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(selectedColor.textColor.opacity(0.9))
                .padding(.bottom, 100)

            // Content
            VStack(alignment: .leading, spacing: 24) {
                Text(keywords.joined(separator: " "))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(selectedColor.textColor)

                Text(oneLiner)
                    .font(.system(size: 20))
                    .foregroundColor(selectedColor.textColor.opacity(0.9))
                    .lineSpacing(6)

                Text("기록에서 발견한 나의 핵심 가치")
                    .font(.system(size: 15))
                    .foregroundColor(selectedColor.textColor.opacity(0.7))
            }
            .padding(.bottom, 100)

            // Footer
            let dateFormatter = DateFormatter()
            Text("\(dateFormatter.string(from: Date()))")
                .font(.system(size: 13))
                .foregroundColor(selectedColor.textColor.opacity(0.6))
                .onAppear {
                    dateFormatter.dateFormat = "yyyy.MM.dd"
                }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(selectedColor.backgroundStyle)
    }
}

// Activity View Controller for sharing
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ColorOption: View {
    let color: CardColor
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.backgroundStyle)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.systemBlue : Color.clear, lineWidth: 2)
                        )

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.systemBlue)
                            .background(Circle().fill(.white).padding(2))
                            .offset(x: 20, y: -20)
                    }
                }

                Text(color.rawValue)
                    .font(.system(size: 13))
                    .foregroundColor(.systemGray)
            }
        }
    }
}

struct ShareButton: View {
    let platform: String
    let icon: String
    let color: Color
    let theme: Theme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)

                Text(platform)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(theme == .dark ? .white : .black)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(theme == .dark ? Color.darkElevated : Color.systemGray6)
            .cornerRadius(16)
        }
    }
}
