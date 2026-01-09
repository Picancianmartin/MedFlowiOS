import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Medicamento.horario) private var medicamentos: [Medicamento]
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea() // Fundo cinza claro
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 1. Header Personalizado
                        headerView
                        
                        // 2. Resumo do Progresso (Gamification sutil)
                        progressoView
                        
                        // 3. Lista de Cards
                        if medicamentos.isEmpty {
                            emptyStateView
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(medicamentos) { item in
                                    // NavigationLink invisível para manter o visual do card
                                    NavigationLink(destination: EditarMedicamentoView(medicamento: item)) {
                                        MedicamentoCard(medicamento: item)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .onDelete(perform: deleteItems) // Swipe to delete funciona melhor em List, mas aqui usamos contexto
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true) // Esconde a nav bar padrão feia
            .sheet(isPresented: $showingAddSheet) {
                AdicionarMedicamentoView()
            }
            // Botão flutuante (FAB)
            .overlay(alignment: .bottomTrailing) {
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Theme.primary)
                        .clipShape(Circle())
                        .shadow(color: Theme.primary.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .padding(24)
            }
        }
    }
    
    // Componente de Header
    var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(Date(), format: .dateTime.weekday(.wide).day().month())
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                    .textCase(.uppercase)
                
                Text("Seus Medicamentos")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
            }
            Spacer()
            // Foto de Perfil (Mock) ou Logo
            Circle()
                .fill(Theme.primary.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(Text("P").bold().foregroundColor(Theme.primary))
        }
    }
    
    // Componente de Progresso
    var progressoView: some View {
        let total = medicamentos.count
        let concluidos = medicamentos.filter { $0.estaConcluido }.count
        let porcentagem = total > 0 ? Double(concluidos) / Double(total) : 0
        
        return HStack {
            VStack(alignment: .leading) {
                Text("Progresso Diário")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("\(concluidos) de \(total) tomados")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            Spacer()
            
            // Gráfico de Rosca simples
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: porcentagem)
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(), value: porcentagem)
            }
            .frame(width: 40, height: 40)
        }
        .padding()
        .background(
            LinearGradient(colors: [Theme.primary, Theme.primary.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(16)
        .shadow(color: Theme.primary.opacity(0.3), radius: 10, y: 5)
    }
    
    // Estado Vazio (Importante para UX)
    var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.shield")
                .font(.system(size: 60))
                .foregroundColor(Theme.textSecondary.opacity(0.3))
                .padding(.top, 40)
            
            Text("Nenhum medicamento")
                .font(.headline)
                .foregroundColor(Theme.textSecondary)
            
            Text("Adicione seu tratamento para começar a acompanhar.")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }

    // Função auxiliar para deletar (precisará adaptar para o swipe do LazyVStack ou adicionar um botão de lixeira no card)
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(medicamentos[index])
            }
        }
    }
}
