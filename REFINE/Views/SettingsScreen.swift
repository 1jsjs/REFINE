import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeManager: ThemeManager
    @State private var iCloudEnabled: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showNotificationSettings: Bool = false
    @State private var showQuestionCustomization: Bool = false

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

                Text("설정")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(themeManager.theme == .dark ? .white : .black)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)

                Text("데이터 관리 및 앱 설정")
                    .font(.system(size: 17))
                    .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)

                // Pieces Per Cycle Setting
                VStack(alignment: .leading, spacing: 16) {
                    Text("조각 수 설정")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(themeManager.theme == .dark ? .white : .black)

                    Text("현재 사이클당 \(appState.piecesPerCycle)개의 조각을 모으고 있습니다")
                        .font(.system(size: 15))
                        .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)

                    HStack(spacing: 12) {
                        ForEach([1, 3, 5, 7], id: \.self) { count in
                            Button(action: {
                                appState.piecesPerCycle = count
                                UserDefaults.standard.set(count, forKey: "piecesPerCycle")
                                alertTitle = "조각 수 변경"
                                alertMessage = "사이클당 \(count)개의 조각을 모으도록 설정되었습니다"
                                showAlert = true
                            }) {
                                VStack(spacing: 4) {
                                    Text("\(count)")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(appState.piecesPerCycle == count ? .white : (themeManager.theme == .dark ? .white : .black))

                                    Text("조각")
                                        .font(.system(size: 13))
                                        .foregroundColor(appState.piecesPerCycle == count ? .white : (themeManager.theme == .dark ? .darkSecondary : .systemGray))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(appState.piecesPerCycle == count ? Color.systemBlue : (themeManager.theme == .dark ? Color.darkElevated2 : .white))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(appState.piecesPerCycle == count ? Color.clear : (themeManager.theme == .dark ? Color.darkSeparator : Color.systemGray4), lineWidth: 1)
                                )
                            }
                        }
                    }
                }
                .padding(20)
                .background(themeManager.theme == .dark ? Color.darkElevated : Color.systemGray6)
                .cornerRadius(16)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)

                // iCloud Auto Backup
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 16) {
                        ZStack {
                            Circle()
                                .fill((iCloudEnabled ? Color.systemBlue : Color.systemGray).opacity(0.15))
                                .frame(width: 48, height: 48)

                            Image(systemName: iCloudEnabled ? "icloud.fill" : "icloud.slash.fill")
                                .font(.system(size: 24))
                                .foregroundColor(iCloudEnabled ? .systemBlue : .systemGray)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("iCloud 자동 백업")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(themeManager.theme == .dark ? .white : .black)

                            Text(iCloudEnabled ? "켜짐 • 모든 기기에서 기록이 자동으로 동기화됩니다" : "꺼짐 • 이 기기에만 저장됩니다")
                                .font(.system(size: 13))
                                .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                                .lineLimit(2)
                        }

                        Spacer()

                        if #available(iOS 17.0, *) {
                            Toggle("", isOn: $iCloudEnabled)
                                .labelsHidden()
                                .onChange(of: iCloudEnabled) { _, newValue in
                                    if newValue {
                                        alertTitle = "iCloud 백업 활성화"
                                        alertMessage = "모든 기기에서 기록이 동기화됩니다."
                                    } else {
                                        alertTitle = "iCloud 백업 비활성화"
                                        alertMessage = "이 기기에만 저장됩니다."
                                    }
                                    showAlert = true
                                }
                        } else {
                            // Fallback on earlier versions
                        }
                    }

                    if iCloudEnabled {
                        Divider()
                            .padding(.vertical, 8)

                        HStack {
                            Text("마지막 백업")
                                .font(.system(size: 13))
                                .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)

                            Spacer()

                            Text("오늘 오후 2:30")
                                .font(.system(size: 13))
                                .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                        }
                    }
                }
                .padding(24)
                .background(themeManager.theme == .dark ? Color.darkElevated : Color.systemGray6)
                .cornerRadius(20)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)

                // Manual Backup Section
                Text("수동 백업하기")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                    .textCase(.uppercase)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)

                VStack(spacing: 0) {
                    ExportButton(title: "모든 형식으로 내보내기", icon: "doc.text", theme: themeManager.theme) {
                        handleExport(format: "모든 형식")
                    }
                    Divider().padding(.leading, 56)

                    ExportButton(title: "텍스트 파일 (.txt)", icon: "doc.plaintext", theme: themeManager.theme) {
                        handleExport(format: "텍스트 파일 (.txt)")
                    }
                    Divider().padding(.leading, 56)

                    ExportButton(title: "JSON 파일", icon: "doc.text", theme: themeManager.theme) {
                        handleExport(format: "JSON 파일")
                    }
                    Divider().padding(.leading, 56)

                    ExportButton(title: "PDF 문서", icon: "doc.richtext", theme: themeManager.theme) {
                        handleExport(format: "PDF 문서")
                    }
                    Divider().padding(.leading, 56)

                    ExportButton(title: "Markdown 파일", icon: "doc.text", theme: themeManager.theme) {
                        handleExport(format: "Markdown 파일")
                    }
                    Divider().padding(.leading, 56)

                    ExportButton(title: "Excel 파일 (.csv)", icon: "tablecells", theme: themeManager.theme, showDivider: false) {
                        handleExport(format: "Excel 파일 (.csv)")
                    }
                }
                .background(themeManager.theme == .dark ? Color.darkElevated : Color.systemGray6)
                .cornerRadius(16)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)

                // Restore from Backup
                Text("백업에서 복원하기")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                    .textCase(.uppercase)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)

                Button(action: {
                    alertTitle = "백업 복원"
                    alertMessage = "백업 파일을 선택해주세요.\n기존 데이터는 보존됩니다."
                    showAlert = true
                }) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.systemRed.opacity(0.15))
                                .frame(width: 48, height: 48)

                            Image(systemName: "arrow.up.doc.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.systemRed)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("파일 선택하기")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(themeManager.theme == .dark ? .white : .black)

                            Text("백업 파일을 불러와 복원합니다")
                                .font(.system(size: 13))
                                .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(themeManager.theme == .dark ? .darkSeparator : Color.systemGray3)
                    }
                    .padding(20)
                    .background(themeManager.theme == .dark ? Color.darkElevated : Color.systemGray6)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)

                // Other Settings
                Text("기타 설정")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                    .textCase(.uppercase)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)

                VStack(spacing: 0) {
                    SettingsRow(icon: "bell.fill", title: "알림 설정", theme: themeManager.theme) {
                        showNotificationSettings = true
                    }
                    Divider().padding(.leading, 56)

                    SettingsRow(icon: "paintpalette.fill", title: "질문 커스터마이징", theme: themeManager.theme) {
                        showQuestionCustomization = true
                    }
                    Divider().padding(.leading, 56)

                    SettingsRow(icon: "info.circle.fill", title: "앱 정보", value: "v1.0.0", theme: themeManager.theme, showChevron: false) {}
                }
                .background(themeManager.theme == .dark ? Color.darkElevated : Color.systemGray6)
                .cornerRadius(16)
                .padding(.horizontal, 24)
                .padding(.bottom, max(40, geometry.safeAreaInsets.bottom + 20))
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(themeManager.theme == .dark ? Color.darkBackground : .white)
        .alert(alertTitle, isPresented: $showAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showNotificationSettings) {
            NotificationSettingsScreen()
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showQuestionCustomization) {
            QuestionCustomizationScreen()
                .environmentObject(themeManager)
        }
    }

    func handleExport(format: String) {
        alertTitle = "내보내기"
        alertMessage = "\(format) 파일로 내보내기가 시작됩니다.\n모든 기록이 저장됩니다."
        showAlert = true
    }
}

struct ExportButton: View {
    let title: String
    let icon: String
    let theme: Theme
    var showDivider: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.systemGray.opacity(0.15))
                        .frame(width: 32, height: 32)

                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(theme == .dark ? .darkSecondary : .systemGray)
                }

                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(theme == .dark ? .white : .black)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(theme == .dark ? .darkSeparator : Color.systemGray3)
            }
            .padding(16)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    var value: String? = nil
    let theme: Theme
    var showChevron: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(theme == .dark ? .darkSecondary : .systemGray)

                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(theme == .dark ? .white : .black)

                Spacer()

                if let value = value {
                    Text(value)
                        .font(.system(size: 15))
                        .foregroundColor(theme == .dark ? .darkSecondary : .systemGray)
                }

                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(theme == .dark ? .darkSeparator : Color.systemGray3)
                }
            }
            .padding(16)
        }
    }
}
