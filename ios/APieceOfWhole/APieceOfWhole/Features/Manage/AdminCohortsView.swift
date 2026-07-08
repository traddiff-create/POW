import SwiftUI

struct AdminCohortsView: View {
    @State private var cohorts: [Cohort] = []
    @State private var isLoading = true
    @State private var showNew = false

    var body: some View {
        ZStack {
            Color.hereBackground.ignoresSafeArea()
            if isLoading {
                ProgressView()
            } else {
                List(cohorts) { cohort in
                    NavigationLink(destination: CohortEditView(cohort: cohort) {
                        Task { await load() }
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(cohort.name)
                                .font(.hereLabel)
                                .foregroundStyle(Color.hereForeground)
                            HStack {
                                Text(cohort.isOpen ? "Open" : "Closed")
                                    .font(.hereCaption)
                                    .foregroundStyle(cohort.isOpen ? Color.hereSage : Color.hereMuted)
                                Spacer()
                                Text(cohort.formattedPrice)
                                    .font(.hereCaption)
                                    .foregroundStyle(Color.hereMuted)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.hereBackground)
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
                        .foregroundStyle(Color.hereSage)
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
                Color.hereBackground.ignoresSafeArea()
                VStack(spacing: 20) {
                    HereTextField(label: "Name", text: $name, placeholder: "Spring 2025 Cohort")
                    HereTextField(label: "Description", text: $description, placeholder: "Optional", axis: .vertical)
                    HereTextField(label: "StoreKit Product ID", text: $storeKitProductID, placeholder: "apow.cohort.8week")
                    Toggle(isOn: $isOpen) {
                        Text("Open for applications")
                            .font(.hereBody)
                            .foregroundStyle(Color.hereForeground)
                    }
                    .tint(Color.hereSage)
                    if let error { Text(error).font(.hereCaption).foregroundStyle(Color.hereError) }
                    Spacer()
                    HereButton(title: cohort == nil ? "Create Cohort" : "Save Changes", isLoading: isSaving) {
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
