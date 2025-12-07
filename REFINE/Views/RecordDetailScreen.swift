import SwiftUI

struct RecordDetailScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    let entry: DailyEntry

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일 EEEE"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .medium))

                                Text("목록")
                                    .font(.system(size: 17))
                            }
                            .foregroundColor(.systemBlue)
                        }

                        Spacer()
                        
                        Menu {
                            Button(action: {
                                copyToClipboard(entry.text)
                            }) {
                                Label("텍스트 복사", systemImage: "doc.on.doc")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: 20))
                                .foregroundColor(.systemBlue)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, max(60, geometry.safeAreaInsets.top + 20))
                    .padding(.bottom, 24)

                    // Piece Number Badge
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.systemBlue)
                                .frame(width: 48, height: 48)

                            Text("\(entry.pieceNumber)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(entry.pieceNumber)번째 조각")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(themeManager.theme == .dark ? .white : .black)

                            Text("\(entry.cycleNumber)번째 사이클")
                                .font(.system(size: 15))
                                .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)

                    // Date & Time
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dateFormatter.string(from: entry.date))
                            .font(.system(size: 15))
                            .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)

                        Text(timeFormatter.string(from: entry.date))
                            .font(.system(size: 13))
                            .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)

                    // Content
                    Text(entry.text)
                        .font(.system(size: 17))
                        .foregroundColor(themeManager.theme == .dark ? .white : .black)
                        .lineSpacing(6)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                        .textSelection(.enabled)
                        .contextMenu {
                            Button(action: {
                                copyToClipboard(entry.text)
                            }) {
                                Label("복사", systemImage: "doc.on.doc")
                            }
                        }

                    // Images
                    if let images = entry.imageData, !images.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("첨부 사진 (\(images.count)장)")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(themeManager.theme == .dark ? .white : .black)
                                .padding(.horizontal, 24)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(0..<images.count, id: \.self) { index in
                                        if let uiImage = UIImage(data: images[index]) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 200, height: 200)
                                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                            .padding(.bottom, 32)
                        }
                    }

                    // Stats
                    VStack(alignment: .leading, spacing: 16) {
                        Text("통계")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(themeManager.theme == .dark ? .white : .black)
                            .padding(.horizontal, 24)

                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("글자 수")
                                    .font(.system(size: 13))
                                    .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)

                                Text("\(entry.text.count)")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(themeManager.theme == .dark ? .white : .black)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                            .background(themeManager.theme == .dark ? Color.darkElevated : Color.systemGray6)
                            .cornerRadius(16)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("사진")
                                    .font(.system(size: 13))
                                    .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)

                                Text("\(entry.imageData?.count ?? 0)")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(themeManager.theme == .dark ? .white : .black)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                            .background(themeManager.theme == .dark ? Color.darkElevated : Color.systemGray6)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, max(40, geometry.safeAreaInsets.bottom + 20))
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(themeManager.theme == .dark ? Color.darkBackground : .white)
        .navigationBarHidden(true)
    }
    
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        
        // Give haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
