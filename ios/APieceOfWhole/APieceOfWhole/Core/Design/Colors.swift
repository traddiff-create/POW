import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }

    static let hereBackground  = Color(hex: "#F9F7F4")
    static let hereSurface     = Color.white
    static let hereForeground  = Color(hex: "#2C2A28")
    static let hereMuted       = Color(hex: "#2C2A28").opacity(0.55)
    static let hereBorder      = Color(hex: "#2C2A28").opacity(0.12)
    static let hereSage        = Color(hex: "#7A9E7E")
    static let hereSageLight   = Color(hex: "#7A9E7E").opacity(0.12)
    static let hereStone       = Color(hex: "#C4A882")
    static let hereError       = Color(hex: "#C0392B")
}
