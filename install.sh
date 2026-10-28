#!/bin/sh
# Christof 를 /Applications 에 설치하거나 다른 버전으로 바꾼다. 버전을 주지 않으면 최신 릴리스다.
#   sh install.sh          최신
#   sh install.sh v0.1.0   그 버전
# curl 로 받은 파일에는 격리 속성이 붙지 않아 공증 없이도 열린다.
set -eu

if [ "$(sw_vers -productVersion | cut -d. -f1)" -lt 26 ]; then
  echo "Christof 는 macOS 26 이상에서 돌아갑니다." >&2
  exit 1
fi

releases=https://github.com/zzzinho/Christof/releases
url=$releases/latest/download/Christof-macOS.zip
[ $# -gt 0 ] && url=$releases/download/$1/Christof-macOS.zip
app=/Applications/Christof.app
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

curl -fL --progress-bar "$url" -o "$tmp/Christof.zip" || { echo "$url 을 받지 못했습니다. 버전 목록: $releases" >&2; exit 1; }
ditto -x -k "$tmp/Christof.zip" "$tmp"
# 새 버전의 위젯이 뜨도록 돌고 있는 앱과 위젯을 끈다.
pkill -x Christof || true
pkill -x ChristofWidgetExtension || true
rm -rf "$app"
ditto "$tmp/Christof.app" "$app"
open "$app"

echo "Christof $(defaults read "$app/Contents/Info" CFBundleShortVersionString) 을 설치했습니다. 바탕화면을 우클릭 → 위젯 편집 → Christof 를 찾아 놓습니다."
