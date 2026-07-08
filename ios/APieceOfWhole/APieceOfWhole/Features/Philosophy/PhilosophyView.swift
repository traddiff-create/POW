import SwiftUI

struct PhilosophyView: View {
    var body: some View {
        ZStack {
            Color.hereBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    workingLines
                    legsSection
                    beliefsSection
                    closingSection
                }
                .padding(24)
            }
        }
        .navigationTitle("Working Philosophy")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(HerePhilosophy.appName)
                .font(.hereLargeTitle)
                .foregroundStyle(Color.hereForeground)

            Text("Self. Together. Community.")
                .font(.hereTitle2)
                .foregroundStyle(Color.hereSage)

            Text(HerePhilosophy.thesis)
                .font(.hereBody)
                .foregroundStyle(Color.hereMuted)

            Text("This is a living philosophy, not doctrine. It begins with the body, practices peace together, and moves outward into local care.")
                .font(.hereBody)
                .foregroundStyle(Color.hereForeground)
        }
    }

    private var workingLines: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(HerePhilosophy.workingLines, id: \.self) { line in
                Text(line)
                    .font(.hereCallout)
                    .foregroundStyle(Color.hereForeground)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color.hereSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.hereBorder, lineWidth: 1)
                    )
            }
        }
    }

    private var legsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("The Three Legs")
                .font(.hereTitle2)
                .foregroundStyle(Color.hereForeground)

            Text("Self is the foundation. Together is the soul. Community is the invitation outward.")
                .font(.hereBody)
                .foregroundStyle(Color.hereMuted)

            VStack(spacing: 12) {
                ForEach(HereLeg.allCases) { leg in
                    HereCard {
                        HStack(alignment: .top, spacing: 14) {
                            Image(systemName: leg.systemImage)
                                .font(.system(size: 22))
                                .foregroundStyle(Color.hereSage)
                                .frame(width: 34, height: 34)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(leg.title)
                                    .font(.hereLabel)
                                    .foregroundStyle(Color.hereForeground)
                                Text(detail(for: leg))
                                    .font(.hereCallout)
                                    .foregroundStyle(Color.hereMuted)
                            }
                        }
                        .padding(16)
                    }
                }
            }
        }
    }

    private func detail(for leg: HereLeg) -> String {
        switch leg {
        case .selfFoundation:
            return HerePhilosophy.selfCopy
        case .together:
            return HerePhilosophy.togetherCopy
        case .community:
            return HerePhilosophy.communityCopy
        }
    }

    private var beliefsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Core Beliefs")
                .font(.hereTitle2)
                .foregroundStyle(Color.hereForeground)

            ForEach(HerePhilosophy.beliefs) { belief in
                VStack(alignment: .leading, spacing: 4) {
                    Text(belief.title)
                        .font(.hereLabel)
                        .foregroundStyle(Color.hereForeground)
                    Text(belief.body)
                        .font(.hereBody)
                        .foregroundStyle(Color.hereMuted)
                }
            }
        }
    }

    private var closingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("We are not selling transformation. We are building conditions.")
                .font(.hereTitle2)
                .foregroundStyle(Color.hereForeground)

            Text("Safe enough to be honest. Connected enough to grow. Grounded enough to act.")
                .font(.hereBody)
                .foregroundStyle(Color.hereMuted)

            Text("You do not have to have it all figured out. Neither do we. That is part of the point.")
                .font(.hereBody)
                .foregroundStyle(Color.hereMuted)

            Text(HerePhilosophy.attribution)
                .font(.hereCaption)
                .foregroundStyle(Color.hereMuted)
                .padding(.top, 8)
        }
    }
}
