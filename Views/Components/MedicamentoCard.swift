import SwiftUI

struct MedicamentoCard: View {
    let medicamento: Medicamento
    
    // Feedback tátil
    let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        HStack(spacing: 16) {
            // 1. Indicador lateral
            RoundedRectangle(cornerRadius: 4)
                .fill(medicamento.estaConcluido ? Theme.success : Theme.primary)
                .frame(width: 4)
                .padding(.vertical, 8)
            
            // 2. Textos
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(medicamento.nome)
                        .font(.headline)
                        .fontWeight(.bold)
                        .strikethrough(medicamento.estaConcluido)
                        .foregroundColor(medicamento.estaConcluido ? Theme.textSecondary : Theme.textPrimary)
                    
                    if medicamento.estaConcluido {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Theme.success)
                            .font(.caption)
                    }
                }
                
                HStack(spacing: 12) {
                    Label {
                        Text(medicamento.horario, style: .time)
                    } icon: {
                        Image(systemName: "clock")
                    }
                    
                    Label {
                        Text(medicamento.dosagem)
                    } icon: {
                        Image(systemName: "pills")
                    }
                }
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
                
                if !medicamento.notas.isEmpty {
                    Text(medicamento.notas)
                        .font(.caption2)
                        .foregroundColor(Theme.primary)
                        .lineLimit(1)
                        .padding(.top, 2)
                }
            }
            
            Spacer()
            
            // 3. Checkmark
            ZStack {
                Circle()
                    .stroke(medicamento.estaConcluido ? Theme.success : Theme.primary.opacity(0.2), lineWidth: 2)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(medicamento.estaConcluido ? Theme.success.opacity(0.1) : Color.white.opacity(0.01))) 
                
                Image(systemName: medicamento.estaConcluido ? "checkmark" : "circle.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(medicamento.estaConcluido ? Theme.success : Color.clear)
            }
            .onTapGesture {
                marcarComoConcluido()
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: Theme.shadow, radius: 8, x: 0, y: 4)
    }
    
    func marcarComoConcluido() {
        haptic.impactOccurred()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            medicamento.estaConcluido.toggle()
        }
    }
}
