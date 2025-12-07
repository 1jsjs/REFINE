import SwiftUI
import SwiftData

struct ListScreen: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.modelContext) var modelContext
    @Query(sort: \DailyEntry.date, order: .reverse) var allEntries: [DailyEntry]
    @State private var searchQuery: String = ""
    @State private var selectedEntry: DailyEntry?
    @State private var showDetailView: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var entryToDelete: DailyEntry?

    var currentCycleEntries: [DailyEntry] {
        allEntries.filter { $0.cycleNumber == appState.currentCycle }
    }

    var filteredEntries: [DailyEntry] {
        if searchQuery.isEmpty {
            return currentCycleEntries
        }
        return currentCycleEntries.filter {
            $0.text.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    var body: some View {
        GeometryReader { geometry in
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

            Text("기록 목록")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(themeManager.theme == .dark ? .white : .black)
                .padding(.horizontal, 24)
                .padding(.bottom, 8)

            Text("\(appState.currentCycle)번째 사이클 - 모은 조각 \(currentCycleEntries.count)개")
                .font(.system(size: 17))
                .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)

                TextField("기록 검색...", text: $searchQuery)
                    .font(.system(size: 17))
                    .foregroundColor(themeManager.theme == .dark ? .white : .black)
            }
            .padding(12)
            .background(themeManager.theme == .dark ? Color.darkElevated : Color.systemGray6)
            .cornerRadius(12)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)

            // Records List
            ScrollView {
                if filteredEntries.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: searchQuery.isEmpty ? "doc.text" : "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray3)

                        Text(searchQuery.isEmpty ? "아직 기록이 없습니다" : "검색 결과가 없습니다")
                            .font(.system(size: 17))
                            .foregroundColor(themeManager.theme == .dark ? .darkSecondary : .systemGray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                } else {
                    VStack(spacing: 12) {
                        ForEach(filteredEntries) { entry in
                            RecordCard(entry: entry, theme: themeManager.theme) {
                                selectedEntry = entry
                                showDetailView = true
                            }
                            .contextMenu {
                                Button(action: {
                                    copyToClipboard(entry.text)
                                }) {
                                    Label("복사", systemImage: "doc.on.doc")
                                }
                                
                                Button(role: .destructive, action: {
                                    entryToDelete = entry
                                    showDeleteAlert = true
                                }) {
                                    Label("삭제", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    entryToDelete = entry
                                    showDeleteAlert = true
                                } label: {
                                    Label("삭제", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, max(40, geometry.safeAreaInsets.bottom + 20))
                }
                }
            }
            .background(themeManager.theme == .dark ? Color.darkBackground : .white)
        }
        .sheet(isPresented: $showDetailView) {
            if let entry = selectedEntry {
                RecordDetailScreen(entry: entry)
                    .environmentObject(themeManager)
            }
        }
        .alert("기록 삭제", isPresented: $showDeleteAlert) {
            Button("취소", role: .cancel) {
                entryToDelete = nil
            }
            Button("삭제", role: .destructive) {
                deleteEntry()
            }
        } message: {
            Text("이 기록을 삭제하시겠습니까?\n삭제 후에는 복구할 수 없습니다.")
        }
    }
    
    private func deleteEntry() {
        guard let entry = entryToDelete else { return }
        
        modelContext.delete(entry)
        
        do {
            try modelContext.save()
            print("✅ Entry deleted successfully")
        } catch {
            print("❌ Failed to delete entry: \(error)")
        }
        
        entryToDelete = nil
    }
    
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        
        // Give haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

struct RecordCard: View {
    let entry: DailyEntry
    let theme: Theme
    let action: () -> Void

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 EEEE"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.systemBlue)
                                .frame(width: 32, height: 32)

                            Text("\(entry.pieceNumber)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                        }

                        Text(dateFormatter.string(from: entry.date))
                            .font(.system(size: 15))
                            .foregroundColor(theme == .dark ? .darkSecondary : .systemGray)
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        if let images = entry.imageData, !images.isEmpty {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.systemBlue)
                        }

                        Image(systemName: "chevron.right")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(theme == .dark ? .darkSeparator : Color.systemGray3)
                    }
                }

                Text(entry.text)
                    .font(.system(size: 15))
                    .foregroundColor(theme == .dark ? .white : .black)
                    .lineLimit(3)

                Text("\(entry.text.count)자")
                    .font(.system(size: 13))
                    .foregroundColor(theme == .dark ? .darkSecondary : .systemGray)
            }
            .padding(20)
            .background(theme == .dark ? Color.darkElevated : Color.systemGray6)
            .cornerRadius(16)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
