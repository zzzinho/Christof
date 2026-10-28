#!/bin/sh
# Christof 앱과 위젯, 설정을 지운다. 바탕화면에 놓인 위젯은 앱이 지워지면 함께 사라진다.
set -u

app=/Applications/Christof.app

pkill -x Christof || true
pkill -x ChristofWidgetExtension || true
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -u "$app" 2>/dev/null
rm -rf "$app"
# 앱과 위젯이 함께 쓰는 설정(시각·날씨·이벤트)
defaults delete com.christof.shared 2>/dev/null
rm -f "$HOME/Library/Preferences/com.christof.shared.plist"
# 샌드박스 컨테이너. 터미널에 전체 디스크 접근 권한이 없으면 macOS 의 앱 데이터 보호가 막는다.
for id in com.christof.Christof.Widget com.christof.Christof; do
  rm -rf "$HOME/Library/Containers/$id" 2>/dev/null ||
    echo "~/Library/Containers/$id 는 macOS 가 막아 남겼습니다. 남아도 문제는 없고, 지우려면 Finder 에서 휴지통으로 옮깁니다." >&2
done

echo "Christof 를 지웠습니다."
