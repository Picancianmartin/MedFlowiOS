import SwiftUI

struct SplashView: View {
    // Estado para controlar a troca de tela
    @State private var isActive = false
    
    // Estados da animação
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            // Quando a animação acaba, carrega o app real
            ContentView()
        } else {
            // TELA DE ANIMAÇÃO
            ZStack {
                Theme.primary.ignoresSafeArea() // Fundo Roxo do seu tema
                
                VStack {
                    VStack(spacing: 20) {
                        // Ícone do App
                        Image(systemName: "pills.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                        
                        // Nome do App
                        Text("MediTracker")
                            .font(.custom("Baskerville-Bold", size: 36)) // Fonte elegante
                            .foregroundColor(.white.opacity(0.80))
                    }
                    .scaleEffect(size) // Aqui acontece o Zoom
                    .opacity(opacity)  // Aqui acontece o Fade In
                    .onAppear {
                        // 1. A Animação Visual (0.8s)
                        withAnimation(.easeIn(duration: 1.2)) {
                            self.size = 1.0
                            self.opacity = 1.00
                        }
                    }
                }
            }
            .onAppear {
                // 2. O Timer para trocar de tela (2 segundos totais)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}