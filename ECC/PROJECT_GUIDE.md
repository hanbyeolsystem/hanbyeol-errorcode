# 한별시스템 에러코드 프로젝트 가이드

> 이 문서는 에러코드 검색 시스템의 **현재 상태**와 **다음 작업 이어서 하는 방법**을 정리한 인수인계 문서입니다.
> 마지막 업데이트: **2026-04-22**

---

## 📍 현재 상태 (한눈에)

| 항목 | 값 |
|---|---|
| Live URL | https://hanbyeolsystem.github.io/hanbyeol-errorcode/ |
| GitHub repo | https://github.com/hanbyeolsystem/hanbyeol-errorcode |
| 총 레코드 | **17,082건** |
| 제조사 | 9개 (Sindoh, Canon, Konica Minolta, Samsung, Kyocera, Brother, Epson, HP, Xerox) |
| JSON 크기 | 약 16.22 MB |
| 내부망 NAS 경로 | `\\192.168.0.249\ErrorCode\` |

---

## 🗂 파일 구조

### NAS `\\192.168.0.249\ErrorCode\`
```
index.html                              ← 웹 페이지 (UI + JS)
errors_v2.json                          ← 메인 데이터 (17,082건)
errors_v2.backup_YYYYMMDD.json          ← 날짜별 백업 (복원용)
index.backup_YYYYMMDD.html              ← HTML 백업
.htaccess                               ← NAS 내부 Apache 설정
README.md                               ← 루트 README
sync.bat                                ← 로컬→NAS→GitHub 동기화 스크립트
ECC/                                    ← 에러코드 원본 보관 폴더
├── PROJECT_GUIDE.md                    ← 이 문서
├── README.md
├── ERROR CODE 신제품추가(20121119)_2012111913313.xlsx   ← Brother 원본 (2018)
└── websr_ecode_20260422.xlsx           ← websr 스크래핑 결과 (18,852건)
```

### GitHub repo (동일 구조)
동일한 파일이 GitHub에 미러됨 (`backup_*.json` 제외 — .gitignore 처리).

### 로컬 작업 폴더 (git 스테이징용)
```
C:\Users\UserK\Desktop\nas-ai\nas-ai\hanbyeol-errorcode\
```
⚠️ **데스크탑에 신규 파일 생성 금지**: 모든 결과물은 NAS에 먼저 작성 후 이 폴더로 복사 (git commit용).

---

## 🏗 아키텍처

```
┌──────────────────┐       ┌────────────────────┐
│  원본 자료(xlsx)   │  ⟶  │   ECC/ 폴더 보관    │
│ • Brother xlsx   │       │ (NAS + GitHub)     │
│ • websr.mooo.com │       │                    │
└──────────────────┘       └─────────┬──────────┘
                                     │ 파싱/병합 (Python)
                                     ▼
                           ┌────────────────────┐
                           │  errors_v2.json    │
                           │     17,082건       │
                           └─────────┬──────────┘
                                     │
        ┌────────────────────────────┼────────────────────────────┐
        ▼                            ▼                            ▼
┌───────────────┐         ┌────────────────┐          ┌──────────────────┐
│ NAS 내부 공유  │         │  로컬 git repo  │          │   GitHub repo    │
│ SMB 접속 가능  │         │  (스테이징용)   │   push→  │   Pages 자동배포  │
└───────────────┘         └────────────────┘          └──────────────────┘
                                                               │
                                                               ▼
                                                   https://hanbyeolsystem
                                                   .github.io/hanbyeol-errorcode/
```

---

## 📋 JSON 데이터 스키마

각 레코드:
```json
{
  "id": 12345,                      // 고유 ID (자동증가)
  "model": "TASKalfa 3010S",        // 모델명 (검색용)
  "code": "C1004",                  // 에러 코드
  "cause": "...",                   // 원인 설명
  "solution": "1. ... 2. ...",      // 조치 방법 (번호 매김)
  "category": "구동 시스템",          // 카테고리 (드롭다운용)
  "manufacturer": "Kyocera",        // 제조사 (드롭다운용)
  "tips": "",                       // 추가 팁 (optional)
  "images": [],                     // 미사용 (future)
  "videos": [],                     // 미사용 (future)
  "parts": []                       // 미사용 (future)
}
```

### 카테고리 목록 (자동 추론)
`급지 시스템`, `구동 시스템`, `정착/퓨저`, `스캐너`, `토너/잉크/드럼`, `레이저/이미지`, `통신/네트워크`, `센서`, `전원/고전압`, `팩스`, `메모리/펌웨어`, `보드/PCB`, `기타`

### 제조사 목록 (9개)
`Sindoh`, `Canon`, `Konica Minolta`, `Samsung`, `Kyocera`, `Brother`, `Epson`, `HP`, `Xerox`

---

## 🔧 핵심 작업 시나리오

### 1) 단순 데이터 편집 (에러코드 몇 개 수정)

1. **로컬 repo에서 수정** (또는 NAS에서 직접 편집):
   - `C:\Users\UserK\Desktop\nas-ai\nas-ai\hanbyeol-errorcode\errors_v2.json`
2. **sync.bat 더블클릭**:
   - NAS 백업 + 미러 + git push 자동 처리
3. **1~2분 후** GitHub Pages 재배포 확인
4. 브라우저 Ctrl+F5

### 2) 새 제조사/모델 추가 (xlsx 원본이 있을 때)

1. **원본 xlsx를 ECC 폴더에 복사**
   ```
   \\192.168.0.249\ErrorCode\ECC\<새파일>.xlsx
   ```
2. **Python 스크립트로 파싱**:
   ```python
   import openpyxl, json
   wb = openpyxl.load_workbook(r'\\192.168.0.249\ErrorCode\ECC\<새파일>.xlsx')
   # 시트별 루프하여 records 생성
   # manufacturer, model, code, cause, solution, category 매핑
   ```
3. **기존 errors_v2.json 로드 후 병합**:
   - **dedupe key**: `(manufacturer.lower(), model.lower(), code.lower())`
   - 신규 records 는 `max_id + 1` 부터 할당
4. **백업 생성** (`errors_v2.backup_YYYYMMDD.json`) 후 저장
5. **NAS → 로컬 repo 미러 → git push**

### 3) 웹사이트 스크래핑으로 추가

지금까지 사용한 방법 (websr.mooo.com/ecode):

**POST 파라미터:**
```
SCopier=ALL
raSearch_type=code   (또는 word)
Sword=<검색어>
nType=1
```

**응답 파싱 패턴:**
```python
# 각 결과 행:
# <tr onClick="fnSol_Detail('MODEL','CODE')">
#   ...
#   [원인]...[조치방법]...
# </tr>
pat = re.compile(
    r'<tr\s+onClick="fnShow\((\d+)\)".*?<b[^>]*>([^<]+)</b>\s*/\s*<b[^>]*>([^<]+)</b>'
    r'.*?<tr id="iExp\1"\s+onClick="fnSol_Detail\(\'([^\']+)\',\'([^\']+)\'\)"'
    r'.*?<td>(.*?)</td>',
    re.DOTALL
)
```

**포괄 수집 팁:**
- 서버는 클라이언트 길이 검증을 강제하지 않음 (1자 검색 가능)
- `code` 필드 검색 시 `0`~`9` + `a`~`z` 총 36회면 전체 데이터 수집 가능
- 각 결과는 `(model, code)` 쌍으로 유일 (dedupe 기준)

**참고 스크립트 위치:**
- `C:\Users\UserK\AppData\Local\Temp\ecode_scrape\scraper.py` (임시, 세션 종료 시 삭제 가능)
- `C:\Users\UserK\AppData\Local\Temp\ecode_scrape\merge.py`
- `C:\Users\UserK\AppData\Local\Temp\ecode_scrape\remove_mfrs.py`

### 4) 특정 제조사/모델 삭제

```python
REMOVE = {'삭제할제조사1', '삭제할제조사2'}
filtered = [e for e in data if e.get('manufacturer') not in REMOVE]
```
백업 → 저장 → 미러 → push.

---

## 💾 백업 규칙

### 자동 백업 (덮어쓰기 전)
- `errors_v2.json` → `errors_v2.backup_YYYYMMDD.json`
- 같은 날 여러 번이면 `_02`, `_03`, ... suffix
- NAS에만 보관 (GitHub는 .gitignore로 제외)

### 현재 보관된 백업
```
errors_v2.backup_20260421.json      ← ADS 추가 전 (Brother 399건 시점)
errors_v2.backup_20260422.json      ← ADS 추가 시점
errors_v2.backup_20260422_02.json   ← websr 병합 전 (1,182건)
errors_v2.backup_20260422_03.json   ← Dell/DGwox/Ricoh 제거 전 (20,034건)
```

### 복원 방법
```bash
cp \\192.168.0.249\ErrorCode\errors_v2.backup_YYYYMMDD.json \\192.168.0.249\ErrorCode\errors_v2.json
# 그 후 sync.bat 실행
```

---

## 🌐 index.html (UI) 주요 기능

| 기능 | 구현 위치 |
|---|---|
| 검색 (제조사/카테고리/키워드) | `function search()` |
| 데이터 로드 (fetch) | `function loadData()` |
| 제조사·카테고리 드롭다운 자동 생성 | `function populateFilters()` |
| 제조사별 통계 자동 계산 | `function updateStats()` |
| 결과 표시 (상위 200건 제한) | `const RENDER_LIMIT = 200;` |
| HTML 이스케이프 (XSS 방지) | `function esc()` |

**UI 변경 시 주의:**
- `index.html`은 단일 파일로 자급자족 (CSS/JS 모두 내장)
- 관리자 모드는 제거됨 (2026-04-22)
- 모바일 반응형 유지 (`@media (max-width: 767px)`)

---

## 🚀 GitHub Pages 배포

### 자동 파이프라인
```
git push → GitHub Actions (Pages 빌드) → 1-2분 → 배포 완료
```

### 수동 확인
```bash
export PATH="$PATH:/c/Program Files/GitHub CLI" MSYS_NO_PATHCONV=1
gh api repos/hanbyeolsystem/hanbyeol-errorcode/pages/builds/latest \
  --jq '{status: .status, error: .error.message}'
```
- `status: "built"` 이면 배포 완료
- `status: "building"` 이면 대기
- `error` 가 null 이 아니면 실패 (로그 확인 필요)

### 배포 확인 (curl)
```bash
curl -sL https://hanbyeolsystem.github.io/hanbyeol-errorcode/errors_v2.json \
  | python -c "import json,sys; d=json.load(sys.stdin); print('records:', len(d))"
```

---

## 🔒 권한 및 계정

- **GitHub**: `hanbyeolsystem` 계정 (Public repo 필요, Free plan)
- **Email**: acapaper78@gmail.com
- **gh CLI 인증**: `gh auth login --web` 로 디바이스 코드 방식
- **git config** (이미 설정됨):
  ```
  user.name = hanbyeolsystem
  user.email = acapaper78@gmail.com
  init.defaultBranch = main
  ```
- **NAS 접속**: SMB 공유 (`\\192.168.0.249\ErrorCode`), 포트 80은 다른 홈페이지가 사용 중

---

## ⚙️ 유틸리티 / 참고

### sync.bat (로컬 → NAS → GitHub 일괄)
위치: `\\192.168.0.249\ErrorCode\sync.bat` (또는 로컬 repo 내)

동작:
1. NAS 기존 파일을 `*.backup_YYYYMMDD.*` 로 백업
2. 로컬 → NAS 복사 (index.html, errors_v2.json, ECC/*)
3. git add -A + commit + push

### Python 환경
- Python 3.10 (+3.14 병존)
- 필수 패키지: `openpyxl`, `uvicorn`(FastAPI 프리뷰용)

### 개발자 도구
- 브라우저 콘솔 `errors loaded: 17082` 로그로 로드 확인
- Network 탭에서 `errors_v2.json` 응답 크기/시간 확인 (초기 로딩 5-10초)

---

## 🧭 향후 개선 아이디어

### 단기 (작은 개선)
- [ ] 검색 상위 200건 제한 → 무한 스크롤/페이지네이션
- [ ] 다중 키워드 AND/OR 지원
- [ ] 카테고리 자동 추론 정확도 향상 (현재 키워드 기반)
- [ ] Brother 데이터 `model` 필드 재구조화 (현재 증상이 model로 들어가 있음)
- [ ] 각 레코드에 원본 출처 필드 추가 (xlsx vs websr)

### 중기 (기능 추가)
- [ ] 이미지/동영상 첨부 기능 (`images`, `videos`, `parts` 필드 활용)
- [ ] 즐겨찾기 / 최근 본 에러코드 (localStorage)
- [ ] 관리자 모드 재도입 (데이터 직접 편집)
- [ ] JSON을 제조사별로 분할하여 지연 로딩 (성능 개선)
- [ ] 검색 하이라이트

### 장기 (플랫폼)
- [ ] API 서버로 전환 (FastAPI + SQLite) — 현재 `app/` 폴더에 초안 있음
- [ ] 사용자별 북마크 (로그인 기반)
- [ ] 통계/대시보드 (가장 많이 검색되는 에러코드)

---

## 📞 유지보수 체크리스트

### 월간
- [ ] 백업 파일(`backup_*.json`) 정리 — 한 달 이상 된 것 삭제 또는 아카이브
- [ ] 새 제조사/모델 추가 검토

### 반기
- [ ] GitHub Pages 쿼타 확인 (무료 플랜: 100GB/월 대역폭)
- [ ] `errors_v2.json` 크기 점검 (20MB 넘으면 분할 검토)

### 문제 발생 시
| 증상 | 확인 순서 |
|---|---|
| 검색 안됨 | 콘솔 로그 → fetch 실패? → GitHub Pages 빌드 상태 |
| 페이지 안뜸 | GitHub Pages 빌드 로그 확인 (`gh api .../pages/builds/latest`) |
| JSON 크기 급증 | 중복 레코드 확인 (dedupe key 로 재필터링) |
| 카드 클릭 안됨 | HTML escape / JSON 특수문자 문제 → `esc()` 함수 경유 확인 |

---

## 📜 변경 이력 요약

| 날짜 | 변경 내용 | 레코드 수 |
|---|---|---|
| 2026-04-13 | 초기 버전 (Brother xlsx 기반) | 1,157 |
| 2026-04-21 | GitHub Pages 배포 시작 + UI 버그 수정 | 1,157 |
| 2026-04-22 | ECC/ADS 시트 추가 | 1,182 |
| 2026-04-22 | 관리자 버튼 제거 | 1,182 |
| 2026-04-22 | websr.mooo.com/ecode 스크래핑 병합 | 20,034 |
| 2026-04-22 | Dell/DGwox/Ricoh 제거 | **17,082** |

---

## 🆘 긴급 롤백

**"망했을 때"** 복구 순서:

1. 가장 최근 "정상" 시점의 백업 선택:
   ```
   \\192.168.0.249\ErrorCode\errors_v2.backup_YYYYMMDD[_NN].json
   ```
2. 로컬 repo에도 복사:
   ```bash
   cp "<백업경로>" "C:/Users/UserK/Desktop/nas-ai/nas-ai/hanbyeol-errorcode/errors_v2.json"
   cp "<백업경로>" "\\192.168.0.249\ErrorCode\errors_v2.json"
   ```
3. git 커밋 후 푸시:
   ```bash
   cd "C:/Users/UserK/Desktop/nas-ai/nas-ai/hanbyeol-errorcode"
   git add errors_v2.json
   git commit -m "Rollback to <백업날짜>"
   git push
   ```
4. 1-2분 후 GitHub Pages 재배포 확인.

**GitHub commit 되돌리기 (더 확실한 롤백):**
```bash
git log --oneline -10                    # 복귀할 commit ID 확인
git revert <commit-id>                   # 새 revert commit 생성
git push
```

---

_문서 끝. 궁금한 점이 있으면 이 가이드를 참조하거나 이전 대화 맥락을 확인하세요._
