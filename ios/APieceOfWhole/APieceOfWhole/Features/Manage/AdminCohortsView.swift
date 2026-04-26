import SwiftUI

struct AdminCohortsView: View {
    @State private var cohorts: [Cohort] = []
    @State private var isLoading = true
    @State private var showNew = false

    var body: some View {
        ZStack {
            Color.powBackground.ignoresSafeArea()
            if isLoading {
                ProgressView()
            } else {
                List(cohorts) { cohort in
                    NavigationLink(destination: CohortEditView(cohort: cohort) {
                        Task { await load() }
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(cohort.name)
                                .font(.powLabel)
                                .foregroundStyle(Color.powForeground)
                            HStack {
                                Text(cohort.isOpen ? "Open" : "Closed")
                                    .font(.powCaption)
                                    .foregroundStyle(cohort.isOpen ? Color.powSage : Color.powMuted)
                                Spacer()
                                Text(cohort.formattedPrice)
                                    .font(.powCaption)
                                    .foregroundStyle(Color.powMuted)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.powBackground)
            }
        }
        .navigationTitle("Cohorts")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showNew = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(Color.powSage)
                }
            }
        }
        .sheet(isPresented: $showNew) {
            CohortEditView(cohort: nil) { Task { await load() } }
        }
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        cohorts = (try? await SupabaseService.shared.fetchAllCohorts()) ?? []
        isLoading = false
    }
}

struct CohortEditView: View {
    let cohort: Cohort?
    let onSave: () async -> Void
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var storeKitProductID = ""
    @State private var isOpen = false
    @State private var isSaving = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.powBackground.ignoresSafeArea()
                VStack(spacing: 20) {
                    POWTextField(label: "Name", text: $name, placeholder: "Spring 2025 Cohort")
                    POWTextField(label: "Description", text: $description, placeholder: "Optional", axis: .vertical)
                    POWTextField(label: "StoreKit Product ID", text: $storeKitProductID, placeholder: "apow.cohort.8week")
                    Toggle(isOn: $isOpen) {
                        Text("Open for applications")
                            .font(.powBody)
                            .foregroundStyle(Color.powForeground)
                    }
                    .tint(Color.powSage)
                    if let error { Text(error).font(.powCaption).foregroundStyle(Color.powError) }
                    Spacer()
                    POWButton(title: cohort == nil ? "Create Cohort" : "Save Changes", isLoading: isSaving) {
                        Task { await save() }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(24)
            }
            .navigationTitle(cohort == nil ? "New Cohort" : "Edit Cohort")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear { populate() }
        }
    }

    private func populate() {
        guard let cohort else { return }
        name = cohort.name
        description = cohort.description ?? ""
        storeKitProductID = cohort.storeKitProductID ?? ""
        isOpen = cohort.isOpen
    }

    private func save() async {
        isSaving = true
        error = nil
        let updated = Cohort(
            id: cohort?.id ?? UUID().uuidString,
            name: name.trimmingCharacters(in: .whitespaces),
            slug: cohort?.slug,
            description: description.isEmpty ? nil : description,
            startDate: cohort?.startDate,
            endDate: cohort?.endDate,
            maxParticipants: cohort?.maxParticipants,
            priceCents: cohort?.priceCents ?? 0,
            isOpen: isOpen,
            storeKitProductID: storeKitProductID.isEmpty ? nil : storeKitProductID,
            createdAt: cohort?.createdAt ?? ISO8601DateFormatter().string(from: Date())
        )
        do {
            try await SupabaseService.shared.upsertCohort(updated)
            await onSave()
            dismiss()
        } catch {
            self.error = AppPublicError.message(for: error, context: .management)
        }
        isSaving = false
    }
}
