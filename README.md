[한국어](#korean) | [English](#english)

---

<a id="english"></a>

# Pulse

A lightweight internal API uptime monitoring tool.  
Register HTTP endpoints and Pulse will continuously check them, track latency, and send alerts via AWS SNS when failures exceed your threshold.

---

## Architecture

```
pulse-frontend  (SvelteKit)  →  pulse-backend  (Spring Boot + WebFlux)
                                      ↓                    ↓
                                  DynamoDB              AWS SNS
                               apis / check_results    (alert email)
```

---

## Repositories

| Repo | Description |
|---|---|
| `pulse-frontend` | This repo — SvelteKit dashboard |
| `pulse-backend` | REST API server — Spring Boot + WebFlux |

---

## Quick Start

### 1. AWS Prerequisites

You need an AWS account with the following resources:

**DynamoDB tables**

| Table | Partition key | Sort key | TTL attribute |
|---|---|---|---|
| `apis` | `api_id` (String) | — | — |
| `check_results` | `api_id` (String) | `checked_at` (String) | `ttl` |

**SNS Topic**  
Create a Standard SNS topic and subscribe an email address to it for failure alerts.

**IAM permissions required**

```json
{
  "Effect": "Allow",
  "Action": [
    "dynamodb:PutItem",
    "dynamodb:GetItem",
    "dynamodb:DeleteItem",
    "dynamodb:Scan",
    "dynamodb:Query",
    "sns:Publish"
  ],
  "Resource": [
    "arn:aws:dynamodb:<region>:<account-id>:table/apis",
    "arn:aws:dynamodb:<region>:<account-id>:table/check_results",
    "<sns-topic-arn>"
  ]
}
```

---

### 2. Backend

**Environment variables**

| Variable | Required | Default | Description |
|---|---|---|---|
| `AWS_REGION` | No | `us-east-1` | AWS region |
| `AWS_SNS_TOPIC_ARN` | **Yes** | — | SNS topic ARN for alerts |
| `AWS_ACCESS_KEY_ID` | * | — | AWS credentials |
| `AWS_SECRET_ACCESS_KEY` | * | — | AWS credentials |

> \* Not needed if running on EC2/ECS with an IAM role, or if `~/.aws/credentials` is configured.

**Run**

```sh
cd pulse-backend
./gradlew bootRun
```

Server starts on `http://localhost:8080`.

---

### 3. Frontend

**Environment variables**

None required for development — the Vite dev server proxies `/apis` to `localhost:8080` automatically.

For production, set the backend origin in `vite.config.js` or configure your reverse proxy.

**Run**

```sh
cd pulse-frontend
npm install
npm run dev
```

Opens at `http://localhost:5173`.

---

## Features

- Register any HTTP endpoint for monitoring
- Configurable check interval, timeout, retry count, and alert threshold
- Latency trend chart (last 50 checks)
- Enable / disable monitoring per API
- AWS SNS alerts with cooldown to avoid alert storms

---

<a id="korean"></a>

# Pulse

HTTP 엔드포인트를 등록하면 주기적으로 상태를 체크하고, 응답 시간을 기록하며, 연속 실패 시 AWS SNS로 알림을 보내는 내부 API 모니터링 도구입니다.

---

## 아키텍처

```
pulse-frontend  (SvelteKit)  →  pulse-backend  (Spring Boot + WebFlux)
                                      ↓                    ↓
                                  DynamoDB              AWS SNS
                               apis / check_results    (알림 이메일)
```

---

## 저장소

| 저장소 | 설명 |
|---|---|
| `pulse-frontend` | 이 저장소 — SvelteKit 대시보드 |
| `pulse-backend` | REST API 서버 — Spring Boot + WebFlux |

---

## 빠른 시작

### 1. AWS 사전 준비

AWS 계정과 아래 리소스가 필요합니다.

**DynamoDB 테이블**

| 테이블 | 파티션 키 | 정렬 키 | TTL 속성 |
|---|---|---|---|
| `apis` | `api_id` (String) | — | — |
| `check_results` | `api_id` (String) | `checked_at` (String) | `ttl` |

**SNS 토픽**  
Standard SNS 토픽을 생성하고, 알림을 받을 이메일 주소를 구독으로 추가합니다.

**필요한 IAM 권한**

```json
{
  "Effect": "Allow",
  "Action": [
    "dynamodb:PutItem",
    "dynamodb:GetItem",
    "dynamodb:DeleteItem",
    "dynamodb:Scan",
    "dynamodb:Query",
    "sns:Publish"
  ],
  "Resource": [
    "arn:aws:dynamodb:<region>:<account-id>:table/apis",
    "arn:aws:dynamodb:<region>:<account-id>:table/check_results",
    "<sns-topic-arn>"
  ]
}
```

---

### 2. 백엔드

**환경 변수**

| 변수 | 필수 | 기본값 | 설명 |
|---|---|---|---|
| `AWS_REGION` | 아니오 | `us-east-1` | AWS 리전 |
| `AWS_SNS_TOPIC_ARN` | **예** | — | 알림용 SNS 토픽 ARN |
| `AWS_ACCESS_KEY_ID` | * | — | AWS 자격증명 |
| `AWS_SECRET_ACCESS_KEY` | * | — | AWS 자격증명 |

> \* EC2/ECS에서 IAM 역할로 실행하거나 `~/.aws/credentials`가 설정된 경우 불필요합니다.

**실행**

```sh
cd pulse-backend
./gradlew bootRun
```

`http://localhost:8080`에서 실행됩니다.

---

### 3. 프론트엔드

**환경 변수**

개발 환경에서는 별도 설정이 없습니다. Vite 개발 서버가 `/apis` 요청을 `localhost:8080`으로 자동 프록시합니다.

프로덕션 배포 시에는 `vite.config.js`의 프록시 설정을 백엔드 주소에 맞게 수정하거나, 리버스 프록시를 구성하세요.

**실행**

```sh
cd pulse-frontend
npm install
npm run dev
```

`http://localhost:5173`에서 실행됩니다.

---

## 주요 기능

- HTTP 엔드포인트 등록 및 모니터링
- 호출 주기, 타임아웃, 재시도 횟수, 알림 기준 개별 설정
- 최근 50건 latency 추이 차트
- API별 모니터링 활성화 / 비활성화
- 알림 cooldown으로 알림 폭발 방지
