import SwiftUI

struct MedicamentoAgrupadoCard: View {
    let medicamentos: [Medicamento]
    let todasAsDoses: [Medicamento]
    
    @State private var showingEditSheet = false
    let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    var diasRestantes: String {
        guard let ultimaDoseGeral = todasAsDoses.max(by: { $0.horario < $1.horario })?.horario,
              let primeiraDose = todasAsDoses.first else { return "" }
        
        if primeiraDose.duracaoDias == 0 { return "Uso Contínuo" }
        
        let calendario = Calendar.current
        let hoje = calendario.startOfDay(for: Date())
        let final = calendario.startOfDay(for: ultimaDoseGeral)
        
        let componentes = calendario.dateComponents([.day], from: hoje, to: final)
        
        if let dias = componentes.day {
            if dias < 0 { return "Finalizado" }
            if dias == 0 { return "Último dia" }
            return "Faltam \(dias) dias"
        }
        return ""
    }
    
    var body: some View {
        if let principal = medicamentos.first {
            VStack(alignment: .leading, spacing: 10) {
                
                // 1. CABEÇALHO 
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(principal.nome)
                            .font(.headline.bold())
                            .foregroundColor(Theme.textPrimary)
                            .lineLimit(1)
                        
                        Text(principal.dosagem)
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                        
                        if !diasRestantes.isEmpty {
                            Text(diasRestantes)
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background((diasRestantes == "Uso Contínuo" ? Color.blue : Color.orange).opacity(0.15))
                                .foregroundColor(diasRestantes == "Uso Contínuo" ? .blue : .orange)
                                .cornerRadius(6)
                                .padding(.top, 2)
                        }
                    }
                    
                    Spacer()
                    
                    // Pílula 3D Menor
                    Image(systemName: "pills.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color(hex: "6FEFB6"), Color(hex: "B88AE6"))
                        .font(.system(size: 32)) // Reduzi tamanho (era 42)
                        .rotationEffect(.degrees(-10))
                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 1, y: 1)
                        .padding(.leading, 8)
                }
                
                Divider().overlay(Theme.textSecondary.opacity(0.2))
                
                // 2. LISTA DE HORÁRIOS
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) { // Menos espaço entre os botões
                        ForEach(medicamentos.sorted(by: { $0.horario < $1.horario })) { dose in
                            ChipHorario(dose: dose) { marcarDose(dose) }
                        }
                    }
                    .padding(.vertical, 2)
                }
                
                // 3. BOTÃO EDITAR DESTACADO
                HStack {
                    Spacer()
                    Button(action: { showingEditSheet = true }) {
                        Text("Editar Tratamento")
                            .font(.caption.bold())
                            .foregroundColor(Theme.primary) // Texto Roxo
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Theme.primary.opacity(0.15)) // Fundo Roxo clarinho
                            .clipShape(Capsule()) // Formato arredondado
                    }
                }
            }
            .padding(14)
            .background(Theme.groupedCardBackground)
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .sheet(isPresented: $showingEditSheet) {
                EditarMedicamentoView(medicamento: principal)
            }
        }
    }
    
    func marcarDose(_ dose: Medicamento) {
        haptic.impactOccurred()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            dose.estaConcluido.toggle()
        }
    }
}

// CHIP HORÁRIO
struct ChipHorario: View {
    let dose: Medicamento
    var action: () -> Void
    var estaAtrasado: Bool { dose.horario < Date() && !dose.estaConcluido }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                ZStack {
                    if dose.estaConcluido {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16)) // Ícone menor
                            .foregroundColor(.white)
                    } else {
                        Circle()
                            .stroke(estaAtrasado ? Color.red : Theme.primary.opacity(0.5), lineWidth: 1.5)
                            .frame(width: 14, height: 14) // Círculo menor
                    }
                }
                
                Text(dose.horario, style: .time)
                    .font(.system(size: 13, weight: .semibold, design: .rounded)) // Fonte menor
                    .foregroundColor(dose.estaConcluido ? .white : Theme.textPrimary)
                    .strikethrough(dose.estaConcluido)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Group {
                    if dose.estaConcluido { Theme.success }
                    else if estaAtrasado { Color.red.opacity(0.15) }
                    else { Color(UIColor.tertiarySystemFill) }
                }
            )
            .cornerRadius(10)
        }
    }
}
