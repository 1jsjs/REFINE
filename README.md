# REFINE iOS

iOS SwiftUI 네이티브 앱 프로젝트입니다.

## 프로젝트 개요

REFINE은 7일간의 기록을 통해 자신의 핵심 가치를 발견하고 정제하는 iOS 앱입니다.

### 주요 기능

- **오늘의 기록**: 매일 질문에 답하며 생각을 기록
- **7일 진행 추적**: 현재 진행 상황을 시각적으로 표시
- **분석 및 정제**: 7일간의 기록을 분석하여 핵심 키워드와 한 줄 요약 생성
- **통계**: 작성 패턴과 인사이트 제공
- **기록 목록**: 7일간의 모든 기록 조회
- **주차 관리**: 과거 주차별 히스토리 관리
- **공유**: 결과를 이미지 카드로 생성하여 SNS 공유
- **다크 모드**: 라이트/다크 테마 지원

## 기술 스택

- **프레임워크**: SwiftUI
- **최소 버전**: iOS 16.0+
- **언어**: Swift 5.9+
- **아키텍처**: MVVM 패턴
- **상태 관리**: `@StateObject`, `@EnvironmentObject`

## 프로젝트 구조

```
REFINE-iOS/
├── REFINE-iOS/
│   ├── REFINEApp.swift          # 앱 진입점
│   ├── ContentView.swift         # 메인 네비게이션 뷰
│   ├── Models/
│   │   ├── AppState.swift        # 앱 전역 상태 관리
│   │   └── ThemeManager.swift    # 테마 관리
│   ├── Views/
│   │   ├── DashboardScreen.swift # 대시보드 화면
│   │   ├── HomeScreen.swift      # 기록 작성 화면
│   │   ├── AnalysisScreen.swift  # 분석 중 화면
│   │   ├── ResultScreen.swift    # 결과 화면
│   │   ├── StatsScreen.swift     # 통계 화면
│   │   ├── ListScreen.swift      # 기록 목록 화면
│   │   ├── WeeksScreen.swift     # 주차 관리 화면
│   │   ├── ShareScreen.swift     # 공유 화면
│   │   └── SettingsScreen.swift  # 설정 화면
│   └── Utilities/
│       └── Colors.swift          # 커스텀 컬러 정의
└── README.md
```

## 설치 및 실행

### 요구사항

- macOS Ventura (13.0) 이상
- Xcode 15.0 이상
- iOS 16.0+ 디바이스 또는 시뮬레이터

### 실행 방법

1. **프로젝트 열기**
   ```bash
   cd REFINE-iOS
   open REFINE-iOS.xcodeproj
   ```

2. **Xcode에서 프로젝트 설정**
   - 프로젝트 네비게이터에서 REFINE-iOS 선택
   - Signing & Capabilities에서 팀 선택
   - Bundle Identifier 설정

3. **실행**
   - 시뮬레이터 또는 실제 기기 선택
   - `Cmd + R` 또는 Run 버튼 클릭

## 화면 설명

### 1. Dashboard (대시보드)
- 현재 진행 상황 표시
- 빠른 통계 (총 글자 수, 사진 수, 주차)
- 메뉴 항목 (기록, 목록, 통계, 주차, 공유, 설정)
- 다크모드 토글

### 2. Home (오늘의 기록)
- 7일 진행도 표시
- 오늘의 질문
- 텍스트 입력 영역
- 사진 첨부 기능
- 기록 저장 및 정제하기 버튼

### 3. Analysis (분석 중)
- 애니메이션 로딩 화면
- 3초 후 자동으로 결과 화면 이동

### 4. Result (결과)
- 핵심 키워드 표시
- 요약 텍스트
- 자소서용 한 줄
- 이미지/텍스트 저장 기능

### 5. Stats (통계)
- 총 글자 수 및 사진 수
- 일별 작성량 차트
- 인사이트 카드

### 6. List (기록 목록)
- 검색 기능
- 7일간의 모든 기록 표시
- 각 기록의 미리보기

### 7. Weeks (주차 관리)
- 전체 통계 요약
- 주차별 히스토리
- 완료된 주차 표시

### 8. Share (공유하기)
- Instagram Story 크기 프리뷰
- 배경 색상 선택 (화이트/블루/퍼플/그라데이션)
- 이미지 저장
- SNS 공유 (Instagram, Twitter)

### 9. Settings (설정)
- iCloud 자동 백업 토글
- 다양한 형식으로 내보내기 (TXT, JSON, PDF, Markdown, CSV)
- 백업 파일 복원
- 알림 설정
- 질문 커스터마이징
- 앱 정보

## 주요 기능 구현

### 상태 관리
```swift
class AppState: ObservableObject {
    @Published var currentScreen: Screen = .dashboard
    @Published var inputText: String = ""
    @Published var currentDay: Int = 3
    // ...
}
```

### 테마 관리
```swift
class ThemeManager: ObservableObject {
    @Published var theme: Theme = .light

    func toggleTheme() {
        theme = theme == .light ? .dark : .light
    }
}
```

### 화면 전환 애니메이션
```swift
.transition(.asymmetric(
    insertion: .move(edge: .trailing),
    removal: .move(edge: .trailing)
))
```

## 디자인 시스템

### 컬러 팔레트
- **Primary Blue**: #007AFF
- **Green**: #34C759
- **Orange**: #FF9500
- **Red**: #FF2D55
- **Purple**: #5856D6
- **Gray Scale**: 시스템 그레이 (6단계)

### 타이포그래피
- **Large Title**: 34pt, Bold
- **Title**: 28pt, Bold
- **Headline**: 17pt, Semibold
- **Body**: 17pt, Regular
- **Caption**: 13pt, Regular

### 레이아웃
- **Padding**: 24pt (표준 수평 여백)
- **Corner Radius**: 12-20pt
- **Spacing**: 8-32pt (컴포넌트 간격)

## 향후 개선 사항

- [ ] CoreData 통합 (로컬 데이터 저장)
- [ ] iCloud 동기화 구현
- [ ] 실제 AI 분석 기능 연동
- [ ] 사진 업로드 및 관리
- [ ] 푸시 알림
- [ ] 위젯 지원
- [ ] iPad 최적화
- [ ] 음성 입력 지원
- [ ] 접근성 개선

## 라이센스

이 프로젝트는 개인 학습 목적으로 만들어졌습니다.

## 기여

버그 리포트나 기능 제안은 Issues를 통해 제출해주세요.

## 연락처

문의사항이 있으시면 이슈를 등록해주세요.
