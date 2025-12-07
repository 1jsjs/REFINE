// REFINE iOS App - AI API Proxy
// Cloudflare Workers를 통해 안전하게 OpenRouter API 호출 (지역 제한 없음)

export default {
  async fetch(request, env) {
    // CORS 헤더 설정 (iOS 앱에서 접근 허용)
    const corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    };

    // OPTIONS 요청 처리 (CORS preflight)
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        status: 204,
        headers: corsHeaders
      });
    }

    // POST 요청만 허용
    if (request.method !== 'POST') {
      return new Response(JSON.stringify({
        error: 'Method not allowed. Use POST.'
      }), {
        status: 405,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }

    try {
      // 요청 본문 파싱
      const body = await request.json();

      // OpenRouter API 키 확인
      if (!env.OPENROUTER_API_KEY) {
        console.error('❌ OPENROUTER_API_KEY is not set in Cloudflare Workers');
        return new Response(JSON.stringify({
          error: 'Server configuration error: API key missing'
        }), {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        });
      }

      console.log(`✅ [REFINE] OpenRouter API 요청 - Model: ${body.model || 'openai/gpt-4o-mini'}`);

      // System message: tone 포함 JSON 강제
      const systemMessage = {
        role: 'system',
        content: `You are a JSON-only assistant.
Return ONLY a single valid JSON object.
Do not wrap it in markdown code blocks.
Do not include any extra text before or after the JSON.

Schema:
{
  "tone": "calm|growth|challenge|joy|reflection|neutral",
  "keywords": [string, string, string, string, string],
  "summary": string,
  "oneLiner": string
}

Rules:
- tone: Choose ONE that best represents the overall emotional tone of the journal entries:
  * calm: 평온, 차분한 성찰
  * growth: 성장, 발전, 학습
  * challenge: 도전, 열정, 투쟁
  * joy: 기쁨, 행복, 감사
  * reflection: 깊은 성찰, 내면 탐색
  * neutral: 중립적, 일상적 기록
- keywords: 3~7 Korean hashtag items (e.g., #성장, #도전, #평온)
- summary: 2~4 sentences in Korean
- oneLiner: One sentence in Korean, no quotes, suitable for job application essays

Return ONLY the JSON object, nothing else.`
      };

      // 기존 messages에 system message 추가
      const messages = [systemMessage, ...(body.messages || [])];

      // OpenRouter API 호출 (OpenAI 호환)
      const openaiResponse = await fetch('https://openrouter.ai/api/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${env.OPENROUTER_API_KEY}`,
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://refine-app.com', // OpenRouter 요구사항
          'X-Title': 'REFINE iOS App', // OpenRouter 요구사항
        },
        body: JSON.stringify({
          model: body.model || 'openai/gpt-4o-mini',
          messages: messages,
          temperature: body.temperature || 0.7,
          max_tokens: body.max_tokens || 1000,
        })
      });

      // API 응답 확인
      if (!openaiResponse.ok) {
        const errorBody = await openaiResponse.text();
        console.error(`❌ [REFINE] OpenRouter API Error - Status: ${openaiResponse.status}`);
        console.error(`Error Body: ${errorBody}`);

        return new Response(JSON.stringify({
          error: 'OpenRouter API request failed',
          status: openaiResponse.status,
          details: errorBody.substring(0, 200) // 에러 메시지 일부만 반환
        }), {
          status: openaiResponse.status,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        });
      }

      // 성공 응답
      const data = await openaiResponse.json();
      const tokensUsed = data.usage?.total_tokens || 0;
      const estimatedCost = (tokensUsed / 1000000) * 0.15; // GPT-4o-mini via OpenRouter

      console.log(`✅ [REFINE] OpenRouter API 성공 - Tokens: ${tokensUsed}, 예상 비용: $${estimatedCost.toFixed(4)}`);

      return new Response(JSON.stringify(data), {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });

    } catch (error) {
      console.error('❌ [REFINE] Internal Error:', error.message);

      return new Response(JSON.stringify({
        error: 'Internal server error',
        message: error.message
      }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }
  }
};
