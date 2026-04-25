import Foundation

// MARK: - Task Router
// Determines which model handles which task.
// Change routing here without touching call sites.

enum AITask {
    case userChat(history: [ChatMessage])   // → GPT-4o  (fast, streaming UX)
    case reasoning(prompt: String)          // → Claude  (complex logic)
    case codeGen(prompt: String)            // → Claude  (best at code)
    case quickClassify(text: String)        // → GPT-4o mini (cheap + fast)
    case imageGen(prompt: String)           // → gpt-image-2
}

struct ChatMessage: Codable {
    let role: String    // "user" | "assistant" | "system"
    let content: String
}

struct AIResponse {
    let text: String
    let model: String
    let provider: AIProvider
}

enum AIProvider { case openai, claude }

// MARK: - AIService

@Observable
final class AIService {

    private let openAIKey: String
    private let claudeKey: String

    private let openAIBase = "https://api.openai.com/v1"
    private let claudeBase = "https://api.anthropic.com/v1"

    init() {
        // Keys pulled from environment — never hardcode
        openAIKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
        claudeKey = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"] ?? ""
    }

    // MARK: - Public entry point

    func run(_ task: AITask) async throws -> AIResponse {
        switch task {
        case .userChat(let history):
            return try await openAIChat(messages: history, model: "gpt-4o")

        case .reasoning(let prompt):
            return try await claudeMessage(prompt: prompt, model: "claude-sonnet-4-6")

        case .codeGen(let prompt):
            return try await claudeMessage(prompt: prompt, model: "claude-sonnet-4-6")

        case .quickClassify(let text):
            let msg = [ChatMessage(role: "user", content: text)]
            return try await openAIChat(messages: msg, model: "gpt-4o-mini")

        case .imageGen(let prompt):
            return try await openAIImageGen(prompt: prompt)
        }
    }

    // MARK: - OpenAI Chat

    private func openAIChat(messages: [ChatMessage], model: String) async throws -> AIResponse {
        let url = URL(string: "\(openAIBase)/chat/completions")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": model,
            "messages": messages.map { ["role": $0.role, "content": $0.content] },
            "max_tokens": 1024
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: req)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let choices = json?["choices"] as? [[String: Any]]
        let message = choices?.first?["message"] as? [String: Any]
        let text = message?["content"] as? String ?? ""

        return AIResponse(text: text, model: model, provider: .openai)
    }

    // MARK: - Claude Messages

    private func claudeMessage(prompt: String, model: String) async throws -> AIResponse {
        let url = URL(string: "\(claudeBase)/messages")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue(claudeKey, forHTTPHeaderField: "x-api-key")
        req.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": model,
            "max_tokens": 1024,
            "messages": [["role": "user", "content": prompt]]
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: req)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let content = json?["content"] as? [[String: Any]]
        let text = content?.first?["text"] as? String ?? ""

        return AIResponse(text: text, model: model, provider: .claude)
    }

    // MARK: - OpenAI Image Generation

    private func openAIImageGen(prompt: String) async throws -> AIResponse {
        let url = URL(string: "\(openAIBase)/images/generations")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-image-2",
            "prompt": prompt,
            "n": 1,
            "size": "1024x1024"
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: req)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let dataArr = json?["data"] as? [[String: Any]]
        let imageURL = dataArr?.first?["url"] as? String ?? ""

        return AIResponse(text: imageURL, model: "gpt-image-2", provider: .openai)
    }
}
