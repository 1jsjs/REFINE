# REFINE - Cloudflare Workers (OpenAI API Proxy)

이 Workers는 REFINE iOS 앱에서 OpenAI API를 안전하게 호출하기 위한 프록시 서버입니다.

## 🎯 목적

- **보안**: iOS 앱에 API 키 노출 방지
- **비용 관리**: API 사용량 모니터링
- **에러 핸들링**: 일관된 에러 처리

## 📦 배포 방법

### 1. wrangler CLI 설치

```bash
npm install -g wrangler
```

### 2. Cloudflare 로그인

```bash
wrangler login
```

브라우저가 열리면 Cloudflare 계정으로 로그인하세요.

### 3. OpenAI API 키 설정

```bash
wrangler secret put OPENAI_API_KEY
```

프롬프트에서 OpenAI API 키를 입력하세요 (https://platform.openai.com/api-keys).

### 4. 배포

```bash
wrangler deploy
```

성공하면 다음과 같이 표시됩니다:
```
✨ Deployment complete!
🌍 https://rapid-sound-ba4c.pjs020201.workers.dev
```

## 🧪 테스트

### curl로 테스트

```bash
curl -X POST https://rapid-sound-ba4c.pjs020201.workers.dev \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o-mini",
    "messages": [{"role": "user", "content": "안녕하세요"}],
    "temperature": 0.7
  }'
```

### 예상 응답

```json
{
  "id": "chatcmpl-...",
  "object": "chat.completion",
  "created": 1701234567,
  "model": "gpt-4o-mini",
  "choices": [{
    "index": 0,
    "message": {
      "role": "assistant",
      "content": "안녕하세요! 무엇을 도와드릴까요?"
    },
    "finish_reason": "stop"
  }],
  "usage": {
    "prompt_tokens": 10,
    "completion_tokens": 15,
    "total_tokens": 25
  }
}
```

## 📊 모니터링

### Cloudflare Dashboard에서 확인

1. https://dash.cloudflare.com 로그인
2. Workers & Pages → rapid-sound-ba4c
3. Metrics 탭에서 다음 확인:
   - 요청 수
   - 에러율
   - CPU 사용량

### 로그 확인

```bash
wrangler tail
```

실시간으로 요청 로그를 확인할 수 있습니다.

## 💰 비용

### Cloudflare Workers (무료 티어)
- 100,000 요청/일
- 초과 시: $0.50 / 100만 요청

### OpenAI API (GPT-4o-mini)
- Input: $0.15 / 1M tokens
- Output: $0.60 / 1M tokens
- **1회 분석 예상 비용: ~$0.01**

### 월 예상 비용 (사용자 100명 기준)
- Cloudflare: $0 (무료 티어 내)
- OpenAI: ~$1/월

## 🔒 보안

- ✅ API 키는 Cloudflare Secret에 안전하게 저장
- ✅ iOS 앱에는 API 키 미포함
- ✅ CORS 설정으로 허용된 출처만 접근
- ✅ HTTPS 암호화 통신

## 🛠️ 문제 해결

### API 키가 설정되지 않음

```bash
# API 키 다시 설정
wrangler secret put OPENAI_API_KEY

# 기존 Secret 확인
wrangler secret list
```

### 배포 실패

```bash
# 로그인 상태 확인
wrangler whoami

# 재로그인
wrangler logout
wrangler login
```

### 테스트 응답이 없음

```bash
# 로그 확인
wrangler tail

# 다른 터미널에서 테스트 요청
curl -X POST https://rapid-sound-ba4c.pjs020201.workers.dev ...
```

## 📝 업데이트

코드 수정 후:

```bash
wrangler deploy
```

변경 사항이 즉시 반영됩니다 (다운타임 없음).

## 🔗 관련 링크

- [Cloudflare Workers 문서](https://developers.cloudflare.com/workers/)
- [OpenAI API 문서](https://platform.openai.com/docs/api-reference)
- [wrangler CLI 가이드](https://developers.cloudflare.com/workers/wrangler/)

---

**작성일**: 2024년 12월 3일
**앱**: REFINE iOS
**배포 URL**: https://rapid-sound-ba4c.pjs020201.workers.dev
