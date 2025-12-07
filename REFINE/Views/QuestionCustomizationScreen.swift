import SwiftUI

struct QuestionCustomizationScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss

    @State private var customQuestions: [String] = UserDefaults.standard.stringArray(forKey: "customQuestions") ?? [
        "오늘 가장 몰입했던 순간은 언제인가요?",
        "오늘 배운 것 중 가장 인상 깊었던 것은?",
        "오늘 나를 성장시킨 경험은?",
        "오늘 가장 감사했던 순간은?",
        "내일의 나에게 전하고 싶은 말은?"
    ]
    @State private var newQuestion: String = ""
    @State private var showAddQuestion: Bool = false

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

                                Text("설정")
                                    .font(.system(size: 17))
                            }
                            .foregroundColor(.systemBlue)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, max(60, geometry.safeAreaInsets.top + 20))
                    .padding(.bottom, 24)

                    Text("질문 커스터마이징")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(themeManager.theme == .dark ? .white : .black)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)

                    Text("매일 받을 질문을 자유롭게 수정하세요")
                        .font(.system(size: 17))
                        .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)

                    // Add New Question Button
                    Button(action: {
                        showAddQuestion.toggle()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.systemBlue)

                            Text("새 질문 추가")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(themeManager.theme == .dark ? .white : .black)

                            Spacer()
                        }
                        .padding(20)
                        .background(themeManager.theme == .dark ? Color.darkElevated : Color.systemGray6)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)

                    if showAddQuestion {
                        VStack(spacing: 12) {
                            TextField("새 질문 입력...", text: $newQuestion)
                                .font(.system(size: 17))
                                .padding(16)
                                .background(themeManager.theme == .dark ? Color.darkElevated2 : .white)
                                .cornerRadius(12)

                            HStack(spacing: 12) {
                                Button("취소") {
                                    newQuestion = ""
                                    showAddQuestion = false
                                }
                                .font(.system(size: 17))
                                .foregroundColor(.systemRed)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(themeManager.theme == .dark ? Color.darkElevated : Color.systemGray6)
                                .cornerRadius(12)

                                Button("추가") {
                                    if !newQuestion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        customQuestions.append(newQuestion)
                                        saveQuestions()
                                        newQuestion = ""
                                        showAddQuestion = false
                                    }
                                }
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.systemBlue)
                                .cornerRadius(12)
                            }
                        }
                        .padding(16)
                        .background(themeManager.theme == .dark ? Color.darkElevated : Color.systemGray6)
                        .cornerRadius(16)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }

                    // Questions List
                    Text("질문 목록")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(themeManager.theme == .dark ? .white : .black)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)

                    VStack(spacing: 12) {
                        ForEach(Array(customQuestions.enumerated()), id: \.offset) { index, question in
                            HStack(alignment: .top, spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color.systemBlue.opacity(0.15))
                                        .frame(width: 32, height: 32)

                                    Text("\(index + 1)")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.systemBlue)
                                }

                                Text(question)
                                    .font(.system(size: 15))
                                    .foregroundColor(themeManager.theme == .dark ? .white : .black)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Button(action: {
                                    customQuestions.remove(at: index)
                                    saveQuestions()
                                }) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 16))
                                        .foregroundColor(.systemRed)
                                        .frame(width: 32, height: 32)
                                }
                            }
                            .padding(16)
                            .background(themeManager.theme == .dark ? Color.darkElevated : Color.systemGray6)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)

                    // Info
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 20))
                            .foregroundColor(.systemBlue)

                        Text("매일 무작위로 선택된 질문이 표시됩니다. 최소 1개 이상의 질문이 필요합니다.")
                            .font(.system(size: 15))
                            .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, max(40, geometry.safeAreaInsets.bottom + 20))
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(themeManager.theme == .dark ? Color.darkBackground : .white)
        .navigationBarHidden(true)
    }

    func saveQuestions() {
        UserDefaults.standard.set(customQuestions, forKey: "customQuestions")
    }
}
