import SwiftUI

struct POWButton: View {
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
                        .tint(style == .primary ? .powForeground : .powSage)
                } else {
                    Text(title)
                        .font(.powHeadline)
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
        case .primary: return .powSage
        case .ghost: return .clear
        case .destructive: return .clear
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return .powForeground
        case .ghost: return .powSage
        case .destructive: return .powError
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary: return .clear
        case .ghost: return .powSage
        case .destructive: return .powError
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        POWButton(title: "Primary") {}
        POWButton(title: "Ghost", style: .ghost) {}
        POWButton(title: "Destructive", style: .destructive) {}
        POWButton(title: "Loading", isLoading: true) {}
    }
    .padding()
    .background(Color.powBackground)
}
