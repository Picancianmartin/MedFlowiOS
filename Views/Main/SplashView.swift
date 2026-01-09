import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    
    // Estados de Animação de Entrada
    @State private var baseScale: CGFloat = 0.8
    @State private var baseOpacity: Double = 0.0
    @State private var ringTrim: CGFloat = 0.0
    @State private var pillScale: CGFloat = 0.0
    
    // Estado de Animação de SAÍDA (O Zoom Final)
    @State private var endAnimation: Bool = false
    
    // Cores (Tons Pastéis)
    let softMint = Color(red: 0.55, green: 0.92, blue: 0.78)
    let softPurple = Color(red: 0.85, green: 0.75, blue: 0.95)
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                // 1. Fundo
                LinearGradient(
                    colors: [softMint.opacity(0.3), softPurple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // 2. O ÍCONE CENTRAL
                ZStack {
                    // Base Quadrada
                    RoundedRectangle(cornerRadius: 45, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 250, height: 250)
                        .shadow(color: softPurple.opacity(0.2), radius: 20, x: 10, y: 10)
                        .shadow(color: .white, radius: 10, x: -5, y: -5)
                        .scaleEffect(baseScale)
                        .opacity(baseOpacity)
                    
                    // Sulco
                    Circle()
                        .stroke(Color.gray.opacity(0.05), lineWidth: 15)
                        .frame(width: 180, height: 180)
                        .scaleEffect(baseScale)
                    
                    // Anel de Luz
                    Circle()
                        .trim(from: 0, to: ringTrim)
                        .stroke(
                            LinearGradient(
                                colors: [softMint, .white],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 180, height: 180)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: softMint, radius: 8, x: 0, y: 0)
                    
                    // Pílula 3D
                    ZStack {
                        Capsule().fill(softPurple).frame(width: 70, height: 140)
                        Capsule().fill(softMint).frame(width: 70, height: 140)
                            .mask(VStack { Rectangle().frame(width: 100, height: 70); Spacer() })
                        Capsule()
                            .fill(LinearGradient(colors: [.white.opacity(0.6), .clear], startPoint: .topLeading, endPoint: .center))
                            .frame(width: 60, height: 130)
                            .blur(radius: 2)
                            .padding(4)
                    }
                    .shadow(color: softPurple.opacity(0.4), radius: 15, x: 5, y: 10)
                    .rotationEffect(.degrees(45))
                    .scaleEffect(pillScale)
                }
            }
            // APLICA O ZOOM DE SAÍDA EM TUDO
            .scaleEffect(endAnimation ? 5.0 : 1.0) // Cresce 5x (Zoom In na câmera)
            .opacity(endAnimation ? 0.0 : 1.0)     // Desaparece suavemente
            .onAppear {
                startAnimationSequence()
            }
        }
    }
    
    func startAnimationSequence() {
        // 1. Entrada da Base
        withAnimation(.easeOut(duration: 0.5)) {
            baseScale = 1.0
            baseOpacity = 1.0
        }
        
        // 2. Anel
        withAnimation(.easeInOut(duration: 0.8).delay(0.1)) {
            ringTrim = 0.75
        }
        
        // 3. Pílula
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.3)) {
            pillScale = 1.0
        }
        
        // 4. SAÍDA ÉPICA (Zoom + Fade)
        // Começa em 1.6s
        withAnimation(.easeIn(duration: 0.4).delay(1.6)) {
            endAnimation = true
        }
        
        // 5. Troca de Tela Real
        // Acontece logo após o zoom terminar (1.9s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
            self.isActive = true
        }
    }
}

#Preview {
    SplashView()
}
