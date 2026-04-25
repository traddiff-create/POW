import SwiftUI

// Usage example — delete or move to a real feature view
// Shows how to call AIService from any SwiftUI view

struct AIExampleView: View {
    private let ai = AIService()

    @State private var reply = ""
    @State private var loading = false

    var body: some View {
        VStack(spacing: 16) {
            if loading {
                ProgressView()
            } else {
                Text(reply.isEmpty ? "Tap a button to test" : reply)
                    .padding()
            }

            Button("Ask GPT-4o (user chat)") {
                Task { await ask(.userChat(history: [
                    ChatMessage(role: "user", content: "What's the best bike route in the Black Hills?")
                ])) }
            }

            Button("Ask Claude (reasoning)") {
                Task { await ask(.reasoning(prompt: "What makes a great community app?")) }
            }
        }
        .padding()
    }

    private func ask(_ task: AITask) async {
        loading = true
        do {
            let response = try await ai.run(task)
            reply = "[\(response.model)] \(response.text)"
        } catch {
            reply = "Error: \(error.localizedDescription)"
        }
        loading = false
    }
}
