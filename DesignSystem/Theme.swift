import SwiftUI

struct Theme {
    // Paleta de Cores
    static let primary = Color(hex: "6C5CE7") // Roxo
    static let background = Color(hex: "F4F6F8")
    static let cardBackground = Color.white
    static let textPrimary = Color(hex: "2D3436")
    static let textSecondary = Color.gray
    static let success = Color(hex: "00B894") // Verde
    
    static let shadow = Color.black.opacity(0.1)
}

// Extensão para ler cores HEX
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
