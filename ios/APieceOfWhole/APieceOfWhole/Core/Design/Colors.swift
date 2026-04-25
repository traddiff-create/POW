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

    static let powBackground  = Color(hex: "#F9F7F4")
    static let powSurface     = Color.white
    static let powForeground  = Color(hex: "#2C2A28")
    static let powMuted       = Color(hex: "#2C2A28").opacity(0.55)
    static let powBorder      = Color(hex: "#2C2A28").opacity(0.12)
    static let powSage        = Color(hex: "#7A9E7E")
    static let powSageLight   = Color(hex: "#7A9E7E").opacity(0.12)
    static let powStone       = Color(hex: "#C4A882")
    static let powError       = Color(hex: "#C0392B")
}
