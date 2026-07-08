import SwiftUI

struct HereTextField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var axis: Axis = .horizontal
    var accessibilityID: String?

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.hereCaption)
                .foregroundStyle(Color.hereMuted)

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .textContentType(.init(rawValue: ""))
                } else if axis == .vertical {
                    TextField(placeholder, text: $text, axis: .vertical)
                        .lineLimit(3...8)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                }
            }
            .font(.hereBody)
            .foregroundStyle(Color.hereForeground)
            .padding(12)
            .background(Color.hereSurface)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isFocused ? Color.hereSage : Color.hereBorder, lineWidth: isFocused ? 1.5 : 1)
            )
            .focused($isFocused)
            .accessibilityIdentifier(accessibilityID ?? label)
        }
    }
}
