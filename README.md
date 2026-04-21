# 한별시스템 프린터 에러코드 검색

프린터 에러코드를 제조사·카테고리·키워드로 검색할 수 있는 정적 웹 페이지입니다.

## 🌐 접속

- **배포 주소**: https://hanbyeolsystem.github.io/hanbyeol-errorcode/
- 내부 NAS(선택): http://192.168.0.249/ErrorCode/

## 📦 구성

| 파일 | 설명 |
|---|---|
| `index.html` | UI + 검색 로직 (단일 파일) |
| `errors_v2.json` | 에러코드 데이터 (약 1,157건) |

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

## 🛠 데이터 갱신

1. `errors_v2.json` 파일 수정
2. 커밋 & push → GitHub Pages 자동 재배포 (1~2분)

```bash
git add errors_v2.json
git commit -m "Update error codes"
git push
```

## 📄 라이선스

내부 사용 목적. 데이터 출처는 각 제조사 서비스 매뉴얼.
