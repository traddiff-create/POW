package com.hackathon.utils

// API config — keys injected at runtime, never hardcoded
// Android: read from BuildConfig or encrypted SharedPrefs
// iOS: read from ProcessInfo.processInfo.environment or Keychain

object APIConfig {
    const val OPENAI_BASE    = "https://api.openai.com/v1"
    const val CLAUDE_BASE    = "https://api.anthropic.com/v1"
    const val CLAUDE_VERSION = "2023-06-01"

    // Default models per task type
    const val MODEL_CHAT     = "gpt-4o"
    const val MODEL_MINI     = "gpt-4o-mini"
    const val MODEL_REASON   = "claude-sonnet-4-6"
    const val MODEL_IMAGE    = "gpt-image-2"
    const val MODEL_EMBED    = "text-embedding-3-small"
}
