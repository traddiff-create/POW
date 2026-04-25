package com.hackathon.models

// Task types determine routing — add new ones here, not at call sites
enum class AITask {
    USER_CHAT,       // → GPT-4o  (fast, user-facing)
    REASONING,       // → Claude  (complex logic)
    CODE_GEN,        // → Claude  (best at code)
    QUICK_CLASSIFY,  // → GPT-4o mini (cheap + fast)
    IMAGE_GEN        // → gpt-image-2
}

enum class AIProvider { OPENAI, CLAUDE }

data class ChatMessage(
    val role: String,    // "user" | "assistant" | "system"
    val content: String
)

data class AIRequest(
    val task: AITask,
    val prompt: String,
    val history: List<ChatMessage> = emptyList()
)

data class AIResponse(
    val text: String,
    val model: String,
    val provider: AIProvider,
    val tokensUsed: Int = 0
)
