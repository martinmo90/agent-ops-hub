// config/shadcn-templates/route.anthropic.ts
import { NextRequest } from 'next/server'
import { streamText } from 'ai'
import { anthropic } from '@ai-sdk/anthropic'

export const runtime = 'edge' // (works with Vercel AI SDK on Next.js)

export async function POST(req: NextRequest) {
  const { messages, system } = await req.json()

  // Pick a solid Claude model; adjust via env if you like
  const modelId =
    process.env.ANTHROPIC_MODEL || 'claude-3-5-sonnet-20241022'

  const result = await streamText({
    model: anthropic(modelId),
    messages,
    system, // optional, if your UI sends it
  })

  return result.toAIStreamResponse()
}
