import SwiftUI
import SwiftData

struct HomeScreen: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.modelContext) private var modelContext
    @Query private var allEntries: [DailyEntry]

    @State private var text: String = ""
    @State private var showSaveAlert: Bool = false
    @State private var selectedImages: [Data] = []
    @State private var showImagePicker: Bool = false

    private var currentCycleEntries: [DailyEntry] {
        allEntries.filter { $0.cycleNumber == appState.currentCycle }
    }

    private var currentPieceCount: Int {
        currentCycleEntries.count
    }

    private var todayQuestion: String {
        let questions = UserDefaults.standard.stringArray(forKey: "customQuestions") ?? [
            "오늘 가장 몰입했던 순간은 언제인가요?",
            "오늘 배운 것 중 가장 인상 깊었던 것은?",
            "오늘 나를 성장시킨 경험은?",
            "오늘 가장 감사했던 순간은?",
            "내일의 나에게 전하고 싶은 말은?"
        ]
        let dayIndex = Calendar.current.component(.day, from: Date())
        return questions[dayIndex % questions.count]
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                // Back Button
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
                .padding(.bottom, 16)

            // Progress Indicator
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    ForEach(1...appState.piecesPerCycle, id: \.self) { piece in
                        Circle()
                            .fill(piece <= currentPieceCount ? Color.systemBlue : (themeManager.theme == .dark ? Color.darkSeparator : Color.systemGray5))
                            .frame(width: 8, height: 8)
                    }
                }

                Text("기록 \(currentPieceCount)/\(appState.piecesPerCycle)")
                    .font(.system(size: 13))
                    .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 32)

            // Header
            Text("오늘의 기록")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(themeManager.theme == .dark ? .white : .black)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

            // Today's Question
            Text("Q. \(todayQuestion)")
                .font(.system(size: 15, design: .serif))
                .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

            // Text Input Area
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text("오늘의 생각을 비워내세요...")
                        .font(.system(size: 17))
                        .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                        .padding(.horizontal, 28)
                        .padding(.top, 8)
                }

                TextEditor(text: $text)
                    .font(.system(size: 17))
                    .foregroundColor(themeManager.theme == .dark ? .white : .black)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .padding(.horizontal, 20)
            }
            .frame(minHeight: 200)
            .frame(maxHeight: .infinity)

            // Image Upload Section
            HStack(spacing: 8) {
                Button(action: {
                    showImagePicker = true
                }) {
                    Image(systemName: selectedImages.isEmpty ? "camera" : "photo.on.rectangle.angled")
                        .font(.system(size: 20))
                        .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                        .frame(width: 40, height: 40)
                        .background(themeManager.theme == .dark ? Color.darkElevated : Color.systemGray6)
                        .clipShape(Circle())
                }

                Text(selectedImages.isEmpty ? "사진 최대 10장" : "사진 \(selectedImages.count)장 선택됨")
                    .font(.system(size: 13))
                    .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImages: $selectedImages, maxSelection: 10)
            }

            // Action Buttons
            VStack(spacing: 12) {
                // Save Today Button
                Button(action: {
                    if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        appState.saveEntry(text: text, context: modelContext, images: selectedImages.isEmpty ? nil : selectedImages)
                        showSaveAlert = true
                        selectedImages = []
                    }
                }) {
                    Text("오늘 기록 저장")
                        .font(.system(size: 17))
                        .foregroundColor(.systemBlue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(themeManager.theme == .dark ? Color.darkSeparator : Color.systemGray5, lineWidth: 1)
                        )
                }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.3 : 1.0)

                // REFINE Button
                Button(action: {
                    if currentPieceCount >= appState.piecesPerCycle {
                        appState.navigate(to: .analysis)
                    }
                }) {
                    HStack(spacing: 8) {
                        if currentPieceCount < appState.piecesPerCycle {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 16, weight: .medium))
                        }

                        Text("정제하기 (REFINE)")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(currentPieceCount >= appState.piecesPerCycle ? .white : (themeManager.theme == .dark ? .darkSecondary : .systemGray))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(currentPieceCount >= appState.piecesPerCycle ? Color.systemBlue : (themeManager.theme == .dark ? Color.darkElevated : Color.systemGray5))
                    .cornerRadius(12)
                }
                .disabled(currentPieceCount < appState.piecesPerCycle)
                .opacity(currentPieceCount < appState.piecesPerCycle ? 0.5 : 1.0)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, max(40, geometry.safeAreaInsets.bottom + 20))
            }
            .background(themeManager.theme == .dark ? Color.darkBackground : .white)
        }
        .alert("저장 완료", isPresented: $showSaveAlert) {
            Button("확인", role: .cancel) {
                text = ""
            }
        } message: {
            Text("오늘의 기록이 저장되었습니다")
        }
    }
}
