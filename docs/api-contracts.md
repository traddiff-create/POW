# API Contracts — KMP Shared Interfaces

All interfaces defined here live in `shared/src/commonMain/kotlin/com/hackathon/`.
Platform-specific implementations go in `androidMain/` or `iosMain/`.

---

## Models (`models/`)

```kotlin
// Item.kt — primary data model (rename to match your domain)
data class Item(
    val id: String,
    val title: String,
    val description: String,
    val createdAt: Long,        // epoch millis
    val metadata: Map<String, String> = emptyMap()
)
```

---

## Repository Interfaces (`repository/`)

```kotlin
// ItemRepository.kt
interface ItemRepository {
    suspend fun getAll(): List<Item>
    suspend fun getById(id: String): Item?
    suspend fun save(item: Item): Boolean
    suspend fun delete(id: String): Boolean
}
```

```kotlin
// AIRepository.kt — OpenAI / Claude integration contract
interface AIRepository {
    suspend fun complete(prompt: String, model: AIModel = AIModel.GPT4o): String
    suspend fun chat(messages: List<ChatMessage>): String
}

enum class AIModel { GPT4o, ClaudeSonnet }

data class ChatMessage(val role: String, val content: String)
```

---

## Domain Use Cases (`domain/`)

```kotlin
// GetItemsUseCase.kt
class GetItemsUseCase(private val repository: ItemRepository) {
    suspend operator fun invoke(): Result<List<Item>> = runCatching {
        repository.getAll()
    }
}
```

```kotlin
// AIQueryUseCase.kt
class AIQueryUseCase(private val ai: AIRepository) {
    suspend operator fun invoke(prompt: String): Result<String> = runCatching {
        ai.complete(prompt)
    }
}
```

---

## iOS Binding Notes
- KMP compiles to `shared.xcframework`
- Kotlin `suspend fun` → Swift `async throws` (via `kotlinx-coroutines` bridge)
- Build XCFramework: `./gradlew :shared:assembleXCFramework`
- Add to Xcode: drag `shared.xcframework` into project target

## Android Binding Notes
- Add `:shared` as a Gradle dependency in `android/build.gradle.kts`
- Use `scope.launch { }` or `viewModelScope.launch { }` to call suspend funs

---

## External API Endpoints

### OpenAI (Chat Completions)
- Base URL: `https://api.openai.com/v1`
- Auth: `Authorization: Bearer $OPENAI_API_KEY`
- Primary endpoint: `POST /chat/completions`
- Default model: `gpt-4o`

### Claude (Messages)
- Base URL: `https://api.anthropic.com/v1`
- Auth: `x-api-key: $ANTHROPIC_API_KEY`
- Primary endpoint: `POST /messages`
- Default model: `claude-sonnet-4-6`
