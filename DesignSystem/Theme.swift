import SwiftUI

struct Theme {
    // 1. Cores da Marca
    static let primary = Color(hex: "6C5CE7")
    static let success = Color(hex: "00B894")
    
    // 2. Cores Adaptativas (Dark Mode Ready 🌙)
    
    // Fundo da Tela
    static let background = Color(UIColor.systemGroupedBackground)
    
    // Cards Padrão (Branco no Light / Cinza no Dark)
    static let cardBackground = Color(UIColor.secondarySystemGroupedBackground)
    
    // --- NOVO: Fundo do Card Agrupado (O do seus remédios) ---
    static let groupedCardBackground = Color(UIColor.systemGray6)
    
    // Textos
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    
    // Sombra (Sutil e só aparece onde faz sentido)
    static let shadow = Color.black.opacity(0.1)
}

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
