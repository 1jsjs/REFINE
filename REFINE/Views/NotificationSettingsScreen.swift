import SwiftUI
import UserNotifications

struct NotificationSettingsScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss

    @State private var notificationsEnabled: Bool = false
    @State private var dailyReminderTime: Date = {
        var components = DateComponents()
        components.hour = 21
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    @State private var selectedDays: Set<Int> = Set([1, 2, 3, 4, 5, 6, 7])
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    let weekDays = [
        (1, "월"), (2, "화"), (3, "수"), (4, "목"),
        (5, "금"), (6, "토"), (7, "일")
    ]

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

                    Text("알림 설정")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(themeManager.theme == .dark ? .white : .black)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)

                    Text("기록 작성을 위한 알림을 설정합니다")
                        .font(.system(size: 17))
                        .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)

                    // Notification Toggle
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("알림 활성화")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(themeManager.theme == .dark ? .white : .black)

                                Text(notificationsEnabled ? "매일 알림을 받습니다" : "알림이 꺼져있습니다")
                                    .font(.system(size: 15))
                                    .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                            }

                            Spacer()

                            Toggle("", isOn: $notificationsEnabled)
                                .labelsHidden()
                                .onChange(of: notificationsEnabled) { _, newValue in
                                    if newValue {
                                        requestNotificationPermission()
                                    } else {
                                        cancelAllNotifications()
                                    }
                                }
                        }
                    }
                    .padding(20)
                    .background(themeManager.theme == .dark ? Color.darkElevated : Color.systemGray6)
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)

                    if notificationsEnabled {
                        // Time Picker
                        VStack(alignment: .leading, spacing: 16) {
                            Text("알림 시간")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(themeManager.theme == .dark ? .white : .black)

                            DatePicker("", selection: $dailyReminderTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .onChange(of: dailyReminderTime) { _, _ in
                                    scheduleNotifications()
                                }
                        }
                        .padding(20)
                        .background(themeManager.theme == .dark ? Color.darkElevated : Color.systemGray6)
                        .cornerRadius(16)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)

                        // Day Selection
                        VStack(alignment: .leading, spacing: 16) {
                            Text("알림 요일")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(themeManager.theme == .dark ? .white : .black)

                            HStack(spacing: 8) {
                                ForEach(weekDays, id: \.0) { day, label in
                                    Button(action: {
                                        if selectedDays.contains(day) {
                                            selectedDays.remove(day)
                                        } else {
                                            selectedDays.insert(day)
                                        }
                                        scheduleNotifications()
                                    }) {
                                        Text(label)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(selectedDays.contains(day) ? .white : (themeManager.theme == .dark ? .white : .black))
                                            .frame(width: 44, height: 44)
                                            .background(selectedDays.contains(day) ? Color.systemBlue : (themeManager.theme == .dark ? Color.darkElevated2 : Color.systemGray5))
                                            .clipShape(Circle())
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(themeManager.theme == .dark ? Color.darkElevated : Color.systemGray6)
                        .cornerRadius(16)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                    }

                    // Info
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 20))
                            .foregroundColor(.systemBlue)

                        Text("알림을 활성화하면 설정한 시간에 매일 기록 작성 알림을 받습니다.")
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
        .alert("알림", isPresented: $showAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            checkNotificationStatus()
        }
    }

    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    scheduleNotifications()
                    alertMessage = "알림이 활성화되었습니다"
                    showAlert = true
                } else {
                    notificationsEnabled = false
                    alertMessage = "설정에서 알림 권한을 허용해주세요"
                    showAlert = true
                }
            }
        }
    }

    func scheduleNotifications() {
        cancelAllNotifications()

        let center = UNUserNotificationCenter.current()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: dailyReminderTime)
        let minute = calendar.component(.minute, from: dailyReminderTime)

        for day in selectedDays {
            var dateComponents = DateComponents()
            dateComponents.weekday = day
            dateComponents.hour = hour
            dateComponents.minute = minute

            let content = UNMutableNotificationContent()
            content.title = "오늘의 생각을 기록해보세요"
            content.body = "작은 조각이 모여 당신의 모습을 만듭니다 ✨"
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "daily-reminder-\(day)", content: content, trigger: trigger)

            center.add(request)
        }
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
