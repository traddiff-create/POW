import SwiftUI

struct LearnView: View {
    @State private var resources: [LearningResource] = []
    @State private var selectedLayer: String?
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var error: String?

    private let layers = ["self_regulation", "co_regulation", "community", "agency", "civic_engagement"]
    private let layerLabels: [String: String] = [
        "self_regulation": "Self-Regulation",
        "co_regulation": "Co-Regulation",
        "community": "Community",
        "agency": "Agency",
        "civic_engagement": "Civic Engagement"
    ]

    private var filteredResources: [LearningResource] {
        resources.filter { resource in
            let matchesLayer = selectedLayer.map { resource.layerValues.contains($0) } ?? true
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard matchesLayer, !query.isEmpty else { return matchesLayer }
            let haystack = ([resource.title, resource.subtitle ?? "", resource.summary ?? ""] + resource.tags + resource.subjects)
                .joined(separator: " ")
                .localizedCaseInsensitiveContains(query)
            return haystack
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.powBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    layerFilter
                    philosophyLink
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)

                    if isLoading {
                        ProgressView()
                            .padding(.top, 48)
                        Spacer()
                    } else if let error {
                        errorView(error)
                    } else if filteredResources.isEmpty {
                        emptyView
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 14) {
                                ForEach(filteredResources) { resource in
                                    NavigationLink(destination: LearnResourceDetailView(resource: resource)) {
                                        LearningResourceCard(resource: resource)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(24)
                        }
                    }
                }
            }
            .navigationTitle("Learn")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search readings")
            .task { await load() }
        }
    }

    private var layerFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(label: "All", value: nil)
                ForEach(layers, id: \.self) { layer in
                    filterChip(label: layerLabels[layer] ?? labelize(layer), value: layer)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
        }
    }

    private var philosophyLink: some View {
        NavigationLink(destination: PhilosophyView()) {
            POWCard {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "text.book.closed")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.powSage)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Working Philosophy")
                            .font(.powLabel)
                            .foregroundStyle(Color.powForeground)
                        Text(POWPhilosophy.learnCopy)
                            .font(.powCallout)
                            .foregroundStyle(Color.powMuted)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.powCaption)
                        .foregroundStyle(Color.powMuted)
                }
                .padding(16)
            }
        }
        .buttonStyle(.plain)
    }

    private func filterChip(label: String, value: String?) -> some View {
        let isSelected = selectedLayer == value
        return Button {
            selectedLayer = value
        } label: {
            Text(label)
                .font(.powCallout)
                .foregroundStyle(isSelected ? Color.white : Color.powForeground)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.powSage : Color.powSurface)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(isSelected ? Color.powSage : Color.powBorder, lineWidth: 1))
        }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "text.book.closed")
                .font(.system(size: 48))
                .foregroundStyle(Color.powMuted)
            Text("No readings found")
                .font(.powTitle2)
                .foregroundStyle(Color.powForeground)
            Text("Try a different layer or search.")
                .font(.powBody)
                .foregroundStyle(Color.powMuted)
        }
        .padding(48)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Text(message)
                .font(.powBody)
                .foregroundStyle(Color.powMuted)
                .multilineTextAlignment(.center)
            POWButton(title: "Retry") { Task { await load() } }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func load() async {
        isLoading = true
        error = nil
        do {
            resources = try await SupabaseService.shared.fetchLearningResources()
        } catch {
            self.error = AppPublicError.message(for: error, context: .learn)
        }
        isLoading = false
    }
}

struct LearningResourceCard: View {
    let resource: LearningResource

    var body: some View {
        POWCard {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.powSage.opacity(0.12))
                        .frame(width: 54, height: 54)
                    Image(systemName: iconName)
                        .font(.system(size: 23))
                        .foregroundStyle(Color.powSage)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(resource.title)
                        .font(.powBody)
                        .foregroundStyle(Color.powForeground)
                        .lineLimit(2)

                    if let subtitle = resource.subtitle {
                        Text(subtitle)
                            .font(.powCaption)
                            .foregroundStyle(Color.powMuted)
                            .lineLimit(2)
                    }

                    HStack(spacing: 8) {
                        if let minutes = resource.readingMinutes {
                            Label("\(minutes) min", systemImage: "clock")
                        }
                        Label(statusLabel, systemImage: resource.hasFullText ? "doc.text" : "info.circle")
                    }
                    .font(.powCaption)
                    .foregroundStyle(Color.powMuted)

                    if let layer = resource.layerValues.first {
                        Text(labelize(layer))
                            .font(.powCaption)
                            .foregroundStyle(Color.powMuted)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.powCaption)
                    .foregroundStyle(Color.powMuted)
                    .padding(.top, 4)
            }
            .padding(16)
        }
    }

    private var iconName: String {
        switch resource.contentStatus {
        case "full_text": return "doc.text"
        case "excerpt": return "doc.plaintext"
        default: return "books.vertical"
        }
    }

    private var statusLabel: String {
        switch resource.contentStatus {
        case "full_text": return "Full text"
        case "excerpt": return "Summary"
        default: return "Metadata"
        }
    }
}

struct LearnResourceDetailView: View {
    let resource: LearningResource
    @Environment(AppState.self) var appState
    @State private var loadedResource: LearningResource?
    @State private var isLoading = false
    @State private var error: String?
    @State private var showReflection = false
    @State private var shareEntry: JournalEntry?
    @State private var savedEntry: JournalEntry?

    private var currentResource: LearningResource {
        loadedResource ?? resource
    }

    var body: some View {
        ZStack {
            Color.powBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header

                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else if let error {
                        Text(error)
                            .font(.powCallout)
                            .foregroundStyle(Color.powError)
                    }

                    if let bodyMarkdown = currentResource.bodyMarkdown, currentResource.hasFullText {
                        Divider()
                        markdownText(bodyMarkdown)
                            .font(.powBody)
                            .foregroundStyle(Color.powForeground)
                    } else {
                        excerptOnlyView
                    }

                    reflectionSection
                }
                .padding(24)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadDetail() }
        .sheet(isPresented: $showReflection) {
            LearnReflectionView(resource: currentResource) { entry in
                savedEntry = entry
                showReflection = false
            }
        }
        .sheet(item: $shareEntry) { entry in
            ShareConfirmationView(entry: entry) {
                savedEntry = nil
                shareEntry = nil
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(currentResource.title)
                .font(.powTitle)
                .foregroundStyle(Color.powForeground)

            if let subtitle = currentResource.subtitle {
                Text(subtitle)
                    .font(.powBody)
                    .foregroundStyle(Color.powMuted)
            }

            if let summary = currentResource.summary {
                Text(summary)
                    .font(.powCallout)
                    .foregroundStyle(Color.powMuted)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    if let minutes = currentResource.readingMinutes {
                        metadataPill("\(minutes) min read")
                    }
                    metadataPill(statusLabel(currentResource))
                }
                ForEach(currentResource.layerValues, id: \.self) { layer in
                    metadataPill(labelize(layer))
                }
            }
        }
    }

    private var excerptOnlyView: some View {
        POWCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("Available in summary for v1", systemImage: "info.circle")
                    .font(.powCaption)
                    .foregroundStyle(Color.powMuted)
                Text("This source is part of the reviewed Alexandria shelf, but the full document is not included in the app until rights, formatting, and privacy review are complete.")
                    .font(.powCallout)
                    .foregroundStyle(Color.powForeground)
            }
            .padding(16)
        }
    }

    private var reflectionSection: some View {
        POWCard {
            VStack(alignment: .leading, spacing: 14) {
                Label("Reflect", systemImage: "square.and.pencil")
                    .font(.powCaption)
                    .foregroundStyle(Color.powMuted)

                if let prompt = currentResource.reflectionPrompt {
                    Text(prompt)
                        .font(.powBody)
                        .foregroundStyle(Color.powForeground)
                }

                POWButton(title: "Save Journal Reflection") {
                    showReflection = true
                }

                if let savedEntry, appState.circleID != nil {
                    Button {
                        shareEntry = savedEntry
                    } label: {
                        Label("Share Saved Reflection to Circle", systemImage: "person.3")
                            .font(.powCallout)
                            .foregroundStyle(Color.powSage)
                    }
                }
            }
            .padding(16)
        }
    }

    private func loadDetail() async {
        isLoading = true
        error = nil
        do {
            loadedResource = try await SupabaseService.shared.fetchLearningResource(id: resource.id)
        } catch {
            self.error = AppPublicError.message(for: error, context: .learn)
        }
        isLoading = false
    }

    private func metadataPill(_ text: String) -> some View {
        Text(text)
            .font(.powCaption)
            .foregroundStyle(Color.powMuted)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.powSurface)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.powBorder, lineWidth: 1))
    }

    private func statusLabel(_ resource: LearningResource) -> String {
        switch resource.contentStatus {
        case "full_text": return "Full text"
        case "excerpt": return "Summary"
        default: return "Metadata"
        }
    }

    @ViewBuilder
    private func markdownText(_ markdown: String) -> some View {
        if let attributed = try? AttributedString(markdown: markdown) {
            Text(attributed)
        } else {
            Text(markdown)
        }
    }
}

struct LearnReflectionView: View {
    let resource: LearningResource
    let onSaved: (JournalEntry) -> Void

    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    @State private var bodyText = ""
    @State private var isLoading = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.powBackground.ignoresSafeArea()
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            if let prompt = resource.reflectionPrompt {
                                POWCard {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Label("Prompt", systemImage: "bubble.left.and.quote.bubble.right")
                                            .font(.powCaption)
                                            .foregroundStyle(Color.powMuted)
                                        Text(prompt)
                                            .font(.powBody)
                                            .foregroundStyle(Color.powForeground)
                                    }
                                    .padding(16)
                                }
                            }

                            POWTextField(
                                label: "Your reflection",
                                text: $bodyText,
                                placeholder: "What does this reading open up for you?",
                                axis: .vertical
                            )
                            .frame(minHeight: 220, alignment: .top)

                            if let error {
                                Text(error)
                                    .font(.powCaption)
                                    .foregroundStyle(Color.powError)
                            }
                        }
                        .padding(24)
                    }

                    POWButton(title: "Save to Journal", isLoading: isLoading) {
                        Task { await save() }
                    }
                    .disabled(bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Journal Reflection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func save() async {
        guard let userID = appState.session?.user.id.uuidString else {
            error = "Could not find your user session."
            return
        }
        isLoading = true
        error = nil
        do {
            let entry = try await SupabaseService.shared.createJournalEntry(
                userID: userID,
                cohortID: appState.activeMembership?.cohortID,
                title: "Reflection on \(resource.title)",
                body: bodyText,
                sourceResourceID: resource.id
            )
            onSaved(entry)
            dismiss()
        } catch {
            self.error = AppPublicError.message(for: error, context: .journal)
        }
        isLoading = false
    }
}

private func labelize(_ value: String) -> String {
    value
        .replacingOccurrences(of: "_", with: " ")
        .split(separator: " ")
        .map { $0.prefix(1).uppercased() + $0.dropFirst() }
        .joined(separator: " ")
}
