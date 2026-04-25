import SwiftUI

struct POWTextField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var axis: Axis = .horizontal

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.powCaption)
                .foregroundStyle(Color.powMuted)

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else if axis == .vertical {
                    TextField(placeholder, text: $text, axis: .vertical)
                        .lineLimit(3...8)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                }
            }
            .font(.powBody)
            .foregroundStyle(Color.powForeground)
            .padding(12)
            .background(Color.powSurface)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isFocused ? Color.powSage : Color.powBorder, lineWidth: isFocused ? 1.5 : 1)
            )
            .focused($isFocused)
        }
    }
}
