# Pulse - 화면 기획서

**스택**: Svelte  
**대상**: 내부 도구 (1인 사용)  
**갱신 방식**: 폴링 (10초)

---

## 1. 페이지 구조

```
/          → 목록 페이지 (API 전체 현황)
/:apiId    → 상세 페이지 (특정 API 수집 결과)
```

---

## 2. 목록 페이지 (`/`)

### 구성 요소

**상단**
- 페이지 타이틀 "Pulse"
- API 등록 버튼 → 등록 폼 모달 열기

**API 카드 목록**  
등록된 API를 카드 형태로 나열. 각 카드에 표시할 정보:

| 항목 | 설명 |
|---|---|
| URL | 모니터링 대상 주소 |
| 상태 배지 | `정상` / `실패` / `비활성` |
| 마지막 응답 시간 | latency_ms |
| 마지막 체크 시각 | last_checked_at |
| 연속 실패 횟수 | consecutive_failures (0이면 숨김) |

카드 클릭 시 상세 페이지로 이동.

**상태 배지 기준**
- `정상` — 마지막 체크 success = true
- `실패` — 마지막 체크 success = false
- `비활성` — enabled = false

### 등록 폼 모달

| 필드 | 입력 형식 | 기본값 |
|---|---|---|
| URL | text input | - |
| Method | select (GET / POST) | GET |
| 호출 주기 | number input (초) | 180 |
| 타임아웃 | number input (초) | 5 |
| 재시도 횟수 | number input (0~2) | 2 |
| 알림 기준 (연속 실패) | number input | 3 |
| 알림 cooldown | number input (초) | 3600 |

하단 버튼: `등록` / `취소`

### 폴링
- 10초마다 `GET /apis` 호출해서 카드 목록 갱신
- 상태 변경 시 배지 색상 자연스럽게 전환

---

## 3. 상세 페이지 (`/:apiId`)

### 구성 요소

**상단**
- 뒤로가기 버튼 (`/` 로 이동)
- URL 표시
- 상태 배지
- 활성화 토글 (enabled on/off)
- 삭제 버튼 → 확인 다이얼로그 후 삭제 및 목록으로 이동

**요약 수치** (카드 형태로 가로 나열)

| 항목 | 설명 |
|---|---|
| 마지막 응답 시간 | latency_ms (ms) |
| 최근 24시간 오류율 | 실패 건수 / 전체 건수 (%) |
| 연속 실패 횟수 | consecutive_failures |

**latency 라인 차트**
- X축: 체크 시각
- Y축: latency_ms
- 표시 범위: 최근 50건
- 실패한 시점은 빨간 점으로 표시

**수집 결과 테이블**  
최근 50건, 최신순 정렬

| 열 | 내용 |
|---|---|
| 시각 | checked_at |
| 상태 코드 | status_code |
| 응답 시간 | latency_ms |
| 결과 | 성공 / 실패 배지 |
| 오류 유형 | error_type (실패 시만 표시) |

### 폴링
- 10초마다 `GET /apis/:apiId/results` 호출
- 차트와 테이블 동시 갱신

---

## 4. 파일 구조

```
src/
  ├─ routes/
  │   ├─ +page.svelte         목록 페이지
  │   └─ [apiId]/
  │       └─ +page.svelte     상세 페이지
  ├─ lib/
  │   ├─ components/
  │   │   ├─ ApiCard.svelte       목록 카드
  │   │   ├─ StatusBadge.svelte   상태 배지
  │   │   ├─ RegisterModal.svelte 등록 폼 모달
  │   │   ├─ LatencyChart.svelte  라인 차트
  │   │   └─ ResultTable.svelte   수집 결과 테이블
  │   └─ api.js               fetch 함수 모음 (Spring Boot API 호출)
```

---

## 5. api.js 호출 목록

| 함수명 | 호출 엔드포인트 | 용도 |
|---|---|---|
| `getApis()` | `GET /apis` | 목록 페이지 폴링 |
| `registerApi(body)` | `POST /apis` | API 등록 |
| `deleteApi(apiId)` | `DELETE /apis/:apiId` | API 삭제 |
| `toggleEnabled(apiId)` | `PATCH /apis/:apiId/enabled` | 활성화 토글 |
| `getResults(apiId)` | `GET /apis/:apiId/results?limit=50` | 상세 페이지 폴링 |

---

## 6. 나중에 추가할 것들

- 오류율 추이 차트 (라인 차트 추가)
- 결과 테이블 날짜 범위 필터
- 등록 폼에서 커스텀 헤더 입력
