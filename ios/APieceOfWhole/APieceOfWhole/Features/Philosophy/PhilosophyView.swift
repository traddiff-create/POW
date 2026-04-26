import SwiftUI

struct PhilosophyView: View {
    var body: some View {
        ZStack {
            Color.powBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    workingLines
                    layersSection
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
            Text("A Piece of Whole")
                .font(.powLargeTitle)
                .foregroundStyle(Color.powForeground)

            Text(POWPhilosophy.signatureLine)
                .font(.powTitle2)
                .foregroundStyle(Color.powSage)

            Text(POWPhilosophy.thesis)
                .font(.powBody)
                .foregroundStyle(Color.powMuted)

            Text("This is a living philosophy, not doctrine. It begins with the body and moves outward into relationship, community, agency, civic life, and the living world.")
                .font(.powBody)
                .foregroundStyle(Color.powForeground)
        }
    }

    private var workingLines: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(POWPhilosophy.workingLines, id: \.self) { line in
                Text(line)
                    .font(.powCallout)
                    .foregroundStyle(Color.powForeground)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color.powSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.powBorder, lineWidth: 1)
                    )
            }
        }
    }

    private var layersSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("The Five Layers")
                .font(.powTitle2)
                .foregroundStyle(Color.powForeground)

            Text(POWPhilosophy.spiralCopy)
                .font(.powBody)
                .foregroundStyle(Color.powMuted)

            VStack(spacing: 12) {
                ForEach(POWPhilosophy.layers) { layer in
                    POWCard {
                        HStack(alignment: .top, spacing: 14) {
                            Image(systemName: layer.systemImage)
                                .font(.system(size: 22))
                                .foregroundStyle(Color.powSage)
                                .frame(width: 34, height: 34)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(layer.title)
                                    .font(.powLabel)
                                    .foregroundStyle(Color.powForeground)
                                Text(layer.detail)
                                    .font(.powCallout)
                                    .foregroundStyle(Color.powMuted)
                            }
                        }
                        .padding(16)
                    }
                }
            }
        }
    }

    private var beliefsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Core Beliefs")
                .font(.powTitle2)
                .foregroundStyle(Color.powForeground)

            ForEach(POWPhilosophy.beliefs) { belief in
                VStack(alignment: .leading, spacing: 4) {
                    Text(belief.title)
                        .font(.powLabel)
                        .foregroundStyle(Color.powForeground)
                    Text(belief.body)
                        .font(.powBody)
                        .foregroundStyle(Color.powMuted)
                }
            }
        }
    }

    private var closingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("We are not selling transformation. We are building conditions.")
                .font(.powTitle2)
                .foregroundStyle(Color.powForeground)

            Text("Safe enough to be honest. Connected enough to grow. Grounded enough to act.")
                .font(.powBody)
                .foregroundStyle(Color.powMuted)

            Text("You do not have to have it all figured out. Neither do we. That is part of the point.")
                .font(.powBody)
                .foregroundStyle(Color.powMuted)

            Text(POWPhilosophy.attribution)
                .font(.powCaption)
                .foregroundStyle(Color.powMuted)
                .padding(.top, 8)
        }
    }
}
