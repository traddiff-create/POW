import SwiftUI

struct SpiralView: View {
    @Environment(AppState.self) var appState
    @State private var checkIns: [CheckIn] = []
    @State private var isLoading = true

    private let layers: [(summary: POWLayerSummary, color: Color)] = [
        (POWPhilosophy.layers[0], Color(hex: "#7A9E7E")),
        (POWPhilosophy.layers[1], Color(hex: "#6B8F9E")),
        (POWPhilosophy.layers[2], Color(hex: "#C4A882")),
        (POWPhilosophy.layers[3], Color(hex: "#9E7A8C")),
        (POWPhilosophy.layers[4], Color(hex: "#8E9E7A"))
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.powBackground.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 32) {
                        spiralIntro
                        spiralDiagram
                        weekGrid
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Your Spiral")
            .navigationBarTitleDisplayMode(.large)
            .task { await load() }
        }
    }

    private var spiralIntro: some View {
        POWCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("Inside out", systemImage: "circle.hexagongrid")
                    .font(.powCaption)
                    .foregroundStyle(Color.powMuted)
                Text(POWPhilosophy.signatureLine)
                    .font(.powTitle2)
                    .foregroundStyle(Color.powForeground)
                Text(POWPhilosophy.spiralCopy)
                    .font(.powBody)
                    .foregroundStyle(Color.powMuted)
            }
            .padding(20)
        }
    }

    private var spiralDiagram: some View {
        POWCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("The Five Layers")
                    .font(.powLabel)
                    .foregroundStyle(Color.powForeground)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                VStack(spacing: 0) {
                    ForEach(Array(layers.enumerated()), id: \.offset) { index, layer in
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(layer.color.opacity(isCurrentLayer(index) ? 1.0 : 0.2))
                                    .frame(width: 44, height: 44)
                                Image(systemName: layer.summary.systemImage)
                                    .font(.system(size: 18))
                                    .foregroundStyle(isCurrentLayer(index) ? Color.white : layer.color)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(layer.summary.title)
                                    .font(.powBody)
                                    .foregroundStyle(isCurrentLayer(index) ? Color.powForeground : Color.powMuted)
                                Text(layer.summary.shortDescription)
                                    .font(.powCaption)
                                    .foregroundStyle(Color.powMuted)
                                if isCurrentLayer(index) {
                                    Text("Current focus")
                                        .font(.powCaption)
                                        .foregroundStyle(layer.color)
                                }
                            }
                            Spacer()
                            if isCurrentLayer(index) {
                                Image(systemName: "chevron.right")
                                    .font(.powCaption)
                                    .foregroundStyle(Color.powMuted)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(isCurrentLayer(index) ? layer.color.opacity(0.06) : Color.clear)

                        if index < layers.count - 1 {
                            Divider().padding(.leading, 80)
                        }
                    }
                }
                .padding(.bottom, 4)
            }
        }
    }

    private var weekGrid: some View {
        POWCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("8-Week Journey")
                    .font(.powLabel)
                    .foregroundStyle(Color.powForeground)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                    ForEach(1...8, id: \.self) { week in
                        weekCell(week: week)
                    }
                }
            }
            .padding(20)
        }
    }

    private func weekCell(week: Int) -> some View {
        let completed = weekHasCheckIn(week)
        let isCurrent = currentWeek == week

        return VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(completed ? Color.powSage : (isCurrent ? Color.powSage.opacity(0.15) : Color.powSurface))
                    .frame(width: 48, height: 48)
                    .overlay(Circle().stroke(isCurrent ? Color.powSage : Color.powBorder, lineWidth: isCurrent ? 2 : 1))
                if completed {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.white)
                } else {
                    Text("\(week)")
                        .font(.powBody)
                        .foregroundStyle(isCurrent ? Color.powSage : Color.powMuted)
                }
            }
            Text("Wk \(week)")
                .font(.powCaption)
                .foregroundStyle(Color.powMuted)
        }
    }

    private func isCurrentLayer(_ index: Int) -> Bool {
        guard let week = currentWeek else { return index == 0 }
        // Layers progress through the 8 weeks: weeks 1-2, 3-4, 5-6, 7, 8
        let layerForWeek = [0, 0, 1, 1, 2, 2, 3, 4]
        let safeWeek = min(max(week - 1, 0), layerForWeek.count - 1)
        return layerForWeek[safeWeek] == index
    }

    private var currentWeek: Int? {
        guard let membership = appState.activeMembership,
              let enrolled = parseDate(membership.enrolledAt) else { return nil }
        let days = Calendar.current.dateComponents([.day], from: enrolled, to: Date()).day ?? 0
        return min(max(days / 7 + 1, 1), 8)
    }

    private func weekHasCheckIn(_ week: Int) -> Bool {
        guard let membership = appState.activeMembership,
              let enrolled = parseDate(membership.enrolledAt) else { return false }
        let weekStart = Calendar.current.date(byAdding: .day, value: (week - 1) * 7, to: enrolled)!
        let weekEnd = Calendar.current.date(byAdding: .day, value: week * 7, to: enrolled)!
        return checkIns.contains { ci in
            guard let date = parseDate(ci.createdAt) else { return false }
            return date >= weekStart && date < weekEnd
        }
    }

    private func parseDate(_ string: String) -> Date? {
        ISO8601DateFormatter().date(from: string)
    }

    private func load() async {
        guard let userID = appState.session?.user.id.uuidString else { return }
        checkIns = (try? await SupabaseService.shared.fetchAllCheckIns(userID: userID)) ?? []
        isLoading = false
    }
}
