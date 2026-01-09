import SwiftUI

struct MedicamentoCard: View {
    let medicamento: Medicamento
    
    // Gerador de feedback tátil (vibrar o celular levemente)
    let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        HStack(spacing: 16) {
            // 1. Barra lateral colorida (Indicador visual rápido)
            RoundedRectangle(cornerRadius: 4)
                .fill(medicamento.estaConcluido ? Theme.success : Theme.primary)
                .frame(width: 4)
                .padding(.vertical, 8)
            
            // 2. Ícone e Infos
            VStack(alignment: .leading, spacing: 4) {
                Text(medicamento.nome)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(medicamento.estaConcluido ? Theme.textSecondary : Theme.textPrimary)
                    .strikethrough(medicamento.estaConcluido)
                
                HStack {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(medicamento.horario, style: .time)
                    
                    Text("•")
                    
                    Image(systemName: "pills")
                        .font(.caption2)
                    Text(medicamento.dosagem)
                }
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
            }
            
            Spacer()
            
            // 3. Botão de Check Animado
            Button(action: {
                haptic.impactOccurred() // Vibração
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    medicamento.estaConcluido.toggle()
                }
            }) {
                ZStack {
                    Circle()
                        .stroke(medicamento.estaConcluido ? Theme.success : Theme.primary.opacity(0.3), lineWidth: 2)
                        .frame(width: 32, height: 32)
                    
                    if medicamento.estaConcluido {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Theme.success)
                            .transition(.scale)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: Theme.shadow, radius: 8, x: 0, y: 4) // Sombra "flutuante"
    }
}
