# Christof

고른 지역의 날씨·시각·명절을 창밖 풍경으로 보여 주는 macOS·iOS 위젯입니다. 창문 모양이고, 3pt 도트로 그립니다. 이름은 트루먼 쇼에서 가상 세계를 연출하는 감독 Christof에서 따왔습니다. 이 창문이 가상의 창문이라는 뜻입니다.

| | |
|---|---|
| ![여름 맑은 낮](docs/images/01-summer-clear-day.png) | ![비 오는 오후](docs/images/07-rainy-afternoon.png) |
| ![추석 보름달](docs/images/06-chuseok-full-moon.png) | ![눈 오는 크리스마스](docs/images/10-snowy-christmas-day.png) |

## 보여 주는 것

- **날씨**: 그 지역의 지금 날씨입니다. 맑음, 구름 조금, 흐림, 안개, 이슬비, 비, 눈, 뇌우를 창밖에 그립니다.
- **시각**: 해와 달을 실제 위치에 그리고, 시각에 따라 낮, 해 질 녘, 밤으로 하늘색이 바뀝니다. 벽시계도 그 지역 시각을 가리킵니다.
- **이벤트**
  - 명절·기념일: 설날, 정월대보름, 부처님오신날, 추석, 할로윈, 크리스마스 이브·크리스마스, 새해 첫날
  - 하늘 이벤트: 일출, 일몰, 보름달
  - 이벤트마다 창밖, 옷, 고양이, 방 안 물건, 시계 모양이 바뀝니다.
- **방 안**: 사람과 고양이가 시각에 따라 따로 지내기도 하고, 같이 있거나 같이 밥을 먹기도 합니다. 겨울에는 고양이가 요일마다 다른 색 목도리를 합니다.

위젯에는 글자를 쓰지 않습니다. 지역, 시각, 날씨, 이벤트는 접근성 라벨로 읽어 줍니다. 로그인이나 계정은 없습니다.

지역은 한국 13곳(서울, 부산, 인천, 대구, 대전, 광주, 울산, 세종, 수원, 춘천, 강릉, 전주, 제주) 중에서 위젯 편집에서 고릅니다.

## 설치 (macOS 26 이상)

1. [Releases](https://github.com/zzzinho/Christof/releases/latest)에서 `Christof-macOS.zip` 을 받아 풀고, `Christof.app` 을 응용 프로그램 폴더로 옮깁니다.
2. Apple 공증을 받지 않은 앱이라 터미널에서 격리 속성을 지워야 열립니다.
   ```sh
   xattr -dr com.apple.quarantine /Applications/Christof.app
   ```
3. 앱을 한 번 엽니다. 앱에서 위젯 미리보기를 보고, 시각·날씨·이벤트를 바꿔 볼 수 있습니다.
4. 바탕화면을 우클릭하고 "위젯 편집"을 고른 뒤, Christof 위젯을 바탕화면에 놓습니다.

iOS용은 배포하지 않습니다. 유료 개발자 계정이 없어서입니다. iOS에서는 소스를 빌드해 시뮬레이터에서 실행해 볼 수 있습니다.

## 빌드

Xcode 27이 필요하고, 배포 타깃은 iOS·macOS 26입니다.

```sh
swift test --package-path ChristofKit
xcodebuild -project Christof.xcodeproj -scheme Christof -destination 'platform=macOS' build
xcodebuild -project Christof.xcodeproj -scheme Christof -destination 'generic/platform=iOS Simulator' build
```

`v` 로 시작하는 태그를 올리면 GitHub Actions가 macOS 앱을 빌드해 릴리스에 올립니다.

```sh
git tag v0.2.0 && git push origin v0.2.0
```

## 구조

- `ChristofKit/`: 날씨, 천문, 이벤트 판정, 그리기를 담은 Swift 패키지입니다. 앱과 위젯이 함께 씁니다.
- `Christof/`: 미리보기와 설정을 보여 주는 앱입니다.
- `ChristofWidget/`: 위젯 익스텐션입니다.
- `06-lofi.html`, `DESIGN.md`, `design.css`: 그림 시안입니다. `ChristofKit` 의 그리기는 이 시안을 옮긴 것이고, 같은 장면이면 시안과 같은 칸을 칠합니다.

## 데이터

날씨는 [Open-Meteo](https://open-meteo.com/)에서 받습니다(CC BY 4.0). 해와 달의 위치는 기기에서 계산합니다.
