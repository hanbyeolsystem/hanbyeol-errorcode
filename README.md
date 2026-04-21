# 한별시스템 프린터 에러코드 검색

프린터 에러코드를 제조사·카테고리·키워드로 검색할 수 있는 정적 웹 페이지입니다.

## 🌐 접속

- **배포 주소**: https://hanbyeolsystem.github.io/hanbyeol-errorcode/
- 내부 NAS(선택): http://192.168.0.249/ErrorCode/

## 📦 구성

| 파일 / 폴더 | 설명 |
|---|---|
| `index.html` | UI + 검색 로직 (단일 파일) |
| `errors_v2.json` | 에러코드 데이터 (약 1,157건) |
| `ECC/` | 에러코드 원본 자료 보관 (엑셀 등) |
| `sync.bat` | 로컬 ↔ NAS ↔ GitHub 동기화 스크립트 |

## 🔍 데이터 범위

| 제조사 | 건수 |
|---|---|
| Kyocera | 429 |
| Brother | 399 |
| Canon | 122 |
| Epson | 99 |
| HP | 37 |
| Samsung | 37 |
| Xerox | 34 |
| **합계** | **1,157** |

## 🛠 데이터 갱신 & 동기화

이 프로젝트는 **3개 지점**을 항상 동일하게 유지합니다:

| 위치 | 경로 |
|---|---|
| 로컬 작업 폴더 | `C:\Users\UserK\Desktop\nas-ai\nas-ai\hanbyeol-errorcode\` |
| NAS (내부망) | `\\192.168.0.249\ErrorCode\` |
| GitHub (공개) | https://github.com/hanbyeolsystem/hanbyeol-errorcode |

### 자동 동기화 — `sync.bat` 실행

로컬에서 파일 수정 후 더블클릭:
```
sync.bat
```
동작:
1. NAS의 기존 파일을 `*.backup_YYYYMMDD.*` 로 자동 백업
2. 로컬 → NAS 미러
3. git commit + push (GitHub Pages 자동 재배포 1~2분)

### 수동 단계별 명령

```bash
# 1. NAS 백업 (날짜별)
copy "\\192.168.0.249\ErrorCode\errors_v2.json" "\\192.168.0.249\ErrorCode\errors_v2.backup_20260422.json"

# 2. 로컬 -> NAS
copy errors_v2.json "\\192.168.0.249\ErrorCode\errors_v2.json"

# 3. GitHub
git add errors_v2.json
git commit -m "Update error codes"
git push
```

## 💾 백업 규칙

- 덮어쓰기 전 기존 파일을 `<stem>.backup_YYYYMMDD.<ext>` 로 보존
- 예: `errors_v2.json` → `errors_v2.backup_20260422.json`
- 같은 날 여러 번은 `_02`, `_03` suffix

## 📄 라이선스

내부 사용 목적. 데이터 출처는 각 제조사 서비스 매뉴얼.
