# PDF Convert Anything

작은 macOS 앱으로 PDF 파일을 PNG 슬라이드 이미지로 변환합니다.

## 기능

- PDF 파일 드래그 앤 드롭 변환
- Finder 파일 선택으로 여러 PDF 변환
- 원본 PDF와 같은 폴더에 PNG 저장
- 저장 파일명: `{PDF파일명}_slide_{페이지번호}pages.png`
- 예시: `lecture.pdf` 3페이지 PDF -> `lecture_slide_1pages.png`, `lecture_slide_2pages.png`, `lecture_slide_3pages.png`

## 설치

1. GitHub Releases에서 `PDF-Convert-Anything-v1.0.0.dmg`를 내려받습니다.
2. DMG를 열고 `PDF Convert Anything.app`을 `Applications`로 드래그합니다.
3. 앱을 실행한 뒤 PDF를 드래그하거나 `PDF 선택` 버튼을 누릅니다.

> 현재 빌드는 ad-hoc 서명된 로컬 배포용 앱입니다. Gatekeeper 경고가 나오면 Finder에서 앱을 우클릭한 뒤 `열기`를 선택하세요.

## 사용 방법

1. 앱을 실행합니다.
2. PDF 파일을 창 가운데 드롭하거나 `PDF 선택` 버튼으로 선택합니다.
3. 변환이 끝나면 `출력 폴더` 버튼으로 저장 위치를 엽니다.

## 로컬 개발

```bash
./script/build_and_run.sh
```

Codex 앱에서는 Run 버튼이 `./script/build_and_run.sh`에 연결되어 있습니다.

## DMG 빌드

```bash
./script/package_dmg.sh 1.0.0
```

생성물:

```text
dist/PDF Convert Anything.app
dist/PDF-Convert-Anything-v1.0.0.dmg
```

## 기술 구성

- Swift 5.10
- SwiftUI
- CoreGraphics PDF 렌더링
- Swift Package Manager
- macOS 14 이상
