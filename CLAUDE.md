# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트

macOS·iOS용 위젯. 위젯은 창문 모양이고, 사용자가 고른 지역의 날씨·시간·이벤트를 창밖 풍경으로 보여준다. 이름은 트루먼 쇼에서 가상 세계를 연출하는 감독 Christof에서 따왔다. 이 창문이 가상의 창문이라는 뜻이다.

- 사용자가 지역을 위젯 설정(위젯 편집)에서 고른다. 로그인·계정은 없고, 사용자 로그인이 필요한 기능이나 서비스는 들이지 않는다.
- 날씨: Open-Meteo (API 키 없음). WeatherKit은 유료 개발자 계정이 필요해서 쓰지 않는다.
- 이벤트: 해당 국가의 명절·기념일(설날, 추석, 크리스마스, 할로윈 등)과 해·달 이벤트(일출·일몰·보름달). 캘린더 일정 같은 개인 데이터는 다루지 않는다. 한국부터 만든다.
- 테스트: 코드 서명 인증서가 없어서 iOS 시뮬레이터로 실행을 확인한다. macOS 타깃은 빌드까지만 검증한다.

## 코드 규칙: SRP·OCP

목적은 이벤트를 쉽게 추가·제거·수정하고, 국가별로 확장할 수 있게 하는 것이다.

- 이벤트 하나 = `Occasion` 값 하나. 언제(`OccasionRule`)와 창문 장식(`decorations`)을 함께 정의한다. 이벤트 추가·제거·수정은 국가 프로필의 `occasions` 목록에서 그 값만 건드린다.
- 국가 하나 = `CountryProfile` 타입 하나 (지역 목록, 이벤트, 계절). 새 국가는 `Countries/<국가>/` 에 프로필을 만들고 `CountryRegistry.standard` 에 등록만 한다. 공용 코드는 고치지 않는다.
- 날짜 규칙 종류, 화면 효과, 장식은 각각 타입 하나씩 둔다 (`OccasionRule`, `SceneLayerProvider`). 새 종류는 새 타입으로 추가하고, 종류별로 분기하는 `switch` 를 여러 곳에 늘리지 않는다.
- 데이터 가져오기(날씨·천문·이벤트 판정), 장면 정보 조립(`SceneContextFactory`), 그리기(레이어)는 서로 다른 타입이 맡는다.

## 구조

- `ChristofKit/`: 로직과 그리기를 모두 담은 로컬 Swift 패키지. 앱과 위젯이 함께 쓴다.
  - 흐름: `Region` + 날짜 + `WeatherForecast` → `SceneContextFactory` → `SceneContext` (순수 값, 타임라인 엔트리에 담김) → `WindowSceneComposer` 가 `SceneLayerProvider` 들과 진행 중인 이벤트 장식에서 `WindowLayer` 를 모아 깊이 순으로 정렬 → `WindowView` 가 창틀 안에 그린다.
  - `Occasions/`: 이벤트 모델과 날짜 규칙 타입. 음력 명절은 `Calendar(identifier: .dangi)` 로 계산한다.
  - `Countries/`: 국가 프로필과 레지스트리. 국가와 무관한 하늘 이벤트는 `CelestialOccasions`.
  - `Rendering/Layers`, `Rendering/Decorations`: 기본 효과와 이벤트 장식 레이어.
- `Christof/`: 컨테이너 앱. `ChristofWidget/`: 위젯 익스텐션. 둘 다 iOS·macOS 멀티플랫폼 타깃이다.
