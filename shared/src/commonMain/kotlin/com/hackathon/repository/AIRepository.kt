package com.hackathon.repository

import com.hackathon.models.AIRequest
import com.hackathon.models.AIResponse

interface AIRepository {
    suspend fun complete(request: AIRequest): Result<AIResponse>
}
