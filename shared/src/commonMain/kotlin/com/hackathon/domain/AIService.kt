package com.hackathon.domain

import com.hackathon.models.*
import com.hackathon.repository.AIRepository

// Route strategy — same logic as Swift AIService, single source of truth in KMP
// Wire up via DI: AIService(openAIRepo, claudeRepo)

class AIService(
    private val openAI: AIRepository,
    private val claude: AIRepository
) {
    suspend fun run(request: AIRequest): Result<AIResponse> = when (request.task) {
        AITask.USER_CHAT       -> openAI.complete(request.copy(prompt = modelFor("gpt-4o", request)))
        AITask.REASONING       -> claude.complete(request.copy(prompt = modelFor("claude-sonnet-4-6", request)))
        AITask.CODE_GEN        -> claude.complete(request.copy(prompt = modelFor("claude-sonnet-4-6", request)))
        AITask.QUICK_CLASSIFY  -> openAI.complete(request.copy(prompt = modelFor("gpt-4o-mini", request)))
        AITask.IMAGE_GEN       -> openAI.complete(request)
    }

    private fun modelFor(model: String, request: AIRequest) = request.prompt
    // TODO: inject model name into request or use a config object
}
