import SwiftUI

struct MedicamentoAgrupadoCard: View {
    // Recebe UMA LISTA de remédios (ex: as 3 doses de Dipirona do dia)
    let medicamentos: [Medicamento]
    
    // Feedback tátil
    let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        // Pega o primeiro da lista só para ler Nome e Dosagem (são iguais em todos)
        if let principal = medicamentos.first {
            VStack(alignment: .leading, spacing: 12) {
                
                // 1. CABEÇALHO (Nome e Dosagem)
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(principal.nome)
                            .font(.headline)
                            .foregroundColor(Theme.textPrimary)
                        
                        Text(principal.dosagem)
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                    }
                    Spacer()
                    // Ícone do remédio
                    Image(systemName: "pills.circle.fill")
                        .font(.title2)
                        .foregroundColor(Theme.primary.opacity(0.3))
                }
                
                // 2. LINHA DO TEMPO (Os Bloquinhos)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // Ordena por horário para mostrar na ordem certa (Manhã -> Noite)
                        ForEach(medicamentos.sorted(by: { $0.horario < $1.horario })) { dose in
                            Button(action: { marcarDose(dose) }) {
                                BloquinhoHorario(dose: dose)
                            }
                            .disabled(dose.estaConcluido) // Impede desmarcar sem querer (opcional)
                        }
                    }
                }
            }
            .padding()
            .background(Theme.cardBackground)
            .cornerRadius(16)
            .shadow(color: Theme.shadow, radius: 5, x: 0, y: 2)
        }
    }
    
    func marcarDose(_ dose: Medicamento) {
        haptic.impactOccurred()
        withAnimation(.spring()) {
            dose.estaConcluido.toggle()
        }
    }
}

// SUBCOMPONENTE: O Design do Bloquinho
struct BloquinhoHorario: View {
    let dose: Medicamento
    
    // Verifica se esse é o PRÓXIMO horário a ser tomado (Destaque)
    var ehOProximo: Bool {
        return !dose.estaConcluido && dose.horario > Date().addingTimeInterval(-3600) // Considera "próximo" o que não passou de 1h atrás
    }
    
    var body: some View {
        if dose.estaConcluido {
            // ESTADO 1: CONCLUÍDO (Discreto, só um check)
            HStack(spacing: 4) {
                Image(systemName: "checkmark")
                    .font(.caption2.bold())
                Text(dose.horario, style: .time)
                    .font(.caption2)
                    .strikethrough()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Theme.success.opacity(0.1))
            .foregroundColor(Theme.success)
            .cornerRadius(8)
            
        } else {
            // ESTADO 2: PENDENTE
            VStack(spacing: 2) {
                Text(dose.horario, style: .time)
                    .font(ehOProximo ? .body.bold() : .caption) // Próximo fica MAIOR
                
                if ehOProximo {
                    Text("AGORA")
                        .font(.system(size: 8, weight: .bold))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(4)
                }
            }
            .padding(.horizontal, ehOProximo ? 16 : 10)
            .padding(.vertical, ehOProximo ? 10 : 8)
            // Se for o próximo: Fundo Roxo Cheio. Se for futuro: Borda Roxa.
            .background(ehOProximo ? Theme.primary : Theme.background)
            .foregroundColor(ehOProximo ? .white : Theme.primary)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Theme.primary, lineWidth: ehOProximo ? 0 : 1)
            )
            .scaleEffect(ehOProximo ? 1.05 : 1.0) // Leve zoom no próximo
        }
    }
}