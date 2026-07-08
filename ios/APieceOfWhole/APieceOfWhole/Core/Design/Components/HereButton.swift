import SwiftUI

struct HereButton: View {
    enum Style { case primary, ghost, destructive }

    let title: String
    var style: Style = .primary
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(style == .primary ? .hereForeground : .hereSage)
                } else {
                    Text(title)
                        .font(.hereHeadline)
                        .foregroundStyle(foregroundColor)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isLoading)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return .hereSage
        case .ghost: return .clear
        case .destructive: return .clear
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return .hereForeground
        case .ghost: return .hereSage
        case .destructive: return .hereError
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary: return .clear
        case .ghost: return .hereSage
        case .destructive: return .hereError
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        HereButton(title: "Primary") {}
        HereButton(title: "Ghost", style: .ghost) {}
        HereButton(title: "Destructive", style: .destructive) {}
        HereButton(title: "Loading", isLoading: true) {}
    }
    .padding()
    .background(Color.hereBackground)
}
