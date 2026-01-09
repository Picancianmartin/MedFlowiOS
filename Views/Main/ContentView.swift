import SwiftUI
import SwiftData
internal import Combine


struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Medicamento.horario) private var medicamentos: [Medicamento]
    
    @State private var showingAddSheet = false
    @State private var dataAtual = Date()
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    // --- MAPA DE TODAS AS DOSES ---
    // Agrupa TODOS os medicamentos do banco pelo nome.
    // Isso serve para o card saber onde começa e termina o tratamento inteiro.
    var todasDosesPorNome: [String: [Medicamento]] {
        Dictionary(grouping: medicamentos) { $0.nome }
    }
    
    // --- LÓGICA DE FILTROS ---
    func agruparRemedios(_ lista: [Medicamento]) -> [[Medicamento]] {
        let dicionario = Dictionary(grouping: lista) { $0.nome }
        return dicionario.values.sorted {
            ($0.first?.horario ?? Date()) < ($1.first?.horario ?? Date())
        }
    }

  
    
    var gruposHoje: [[Medicamento]] {
        let lista = medicamentos.filter { Calendar.current.isDateInToday($0.horario) }
        return agruparRemedios(lista)
    }
    
    var gruposProximos: [[Medicamento]] {
        let lista = medicamentos.filter {
            $0.horario >= dataAtual && !Calendar.current.isDateInToday($0.horario) && !$0.estaConcluido
        }
        return agruparRemedios(lista)
    }
    
    var totalHoje: Int { medicamentos.filter { Calendar.current.isDateInToday($0.horario) }.count }
    var concluidosHoje: Int { medicamentos.filter { Calendar.current.isDateInToday($0.horario) && $0.estaConcluido }.count }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerView
                        
                        if totalHoje > 0 {
                            PainelProgressoView(total: totalHoje, concluidos: concluidosHoje)
                        }
                        
                        
                        // --- SEÇÃO 2: TOMAR HOJE ---
                        if !gruposHoje.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Tomar Hoje", systemImage: "sun.max.fill")
                                    .font(.title3.bold()).foregroundColor(Theme.textPrimary).padding(.horizontal, 4)
                                
                                ForEach(gruposHoje, id: \.first!.id) { grupo in
                                    MedicamentoAgrupadoCard(
                                        medicamentos: grupo,
                                        todasAsDoses: todasDosesPorNome[grupo.first?.nome ?? ""] ?? []
                                    )
                                    .shadow(color: Theme.shadow, radius: 5, x: 0, y: 2)
                                }
                            }
                        }
                        
                        // --- SEÇÃO 3: PRÓXIMOS ---
                        if !gruposProximos.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Próximos Dias", systemImage: "calendar")
                                    .font(.headline).foregroundColor(Theme.textSecondary).padding(.top, 10).padding(.horizontal, 4)
                                
                                ForEach(gruposProximos, id: \.first!.id) { grupo in
                                    MedicamentoAgrupadoCard(
                                        medicamentos: grupo,
                                        todasAsDoses: todasDosesPorNome[grupo.first?.nome ?? ""] ?? []
                                    )
                                    .opacity(0.7).saturation(0.8)
                                }
                            }
                        }
                        
                        if medicamentos.isEmpty { EmptyStateView() }
                    }
                    .padding().padding(.bottom, 80)
                }
            }
            .navigationBarHidden(true)
            .onReceive(timer) { input in dataAtual = input }
            .overlay(alignment: .bottomTrailing) {
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                        .font(.title2.bold()).foregroundColor(.white)
                        .frame(width: 60, height: 60).background(Theme.primary).clipShape(Circle())
                        .shadow(color: Theme.primary.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .padding(24)
            }
            .sheet(isPresented: $showingAddSheet) { AdicionarMedicamentoView() }
        }
    }
    
    var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(dataAtual, format: .dateTime.weekday(.wide).day().month())
                    .textCase(.uppercase).font(.caption).foregroundColor(Theme.textSecondary)
                Text("MedFlow").font(.largeTitle).fontWeight(.bold).foregroundColor(Theme.textPrimary)
            }
            Spacer()
        }
    }
}

// --- SUBCOMPONENTES ---

struct PainelProgressoView: View {
    var total: Int
    var concluidos: Int
    
    var porcentagem: Double {
        return total > 0 ? Double(concluidos) / Double(total) : 0
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Progresso Diário")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(concluidos == total ? "Tudo tomado! 🎉" : "\(concluidos) de \(total) concluídos")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            Spacer()
            ZStack {
                Circle().stroke(Color.white.opacity(0.3), lineWidth: 6)
                Circle().trim(from: 0, to: porcentagem)
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(), value: porcentagem)
                Text("\(Int(porcentagem * 100))%")
                    .font(.caption2.bold()).foregroundColor(.white)
            }
            .frame(width: 45, height: 45)
        }
        .padding(20)
        .background(LinearGradient(colors: [Theme.primary, Theme.primary.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(20)
        .shadow(color: Theme.primary.opacity(0.3), radius: 10, y: 5)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 60))
                .foregroundColor(Theme.textSecondary.opacity(0.2))
                .padding(.top, 40)
            Text("Nenhum tratamento").font(.headline).foregroundColor(Theme.textSecondary)
            Text("Adicione seus medicamentos para começar a acompanhar sua saúde.")
                .font(.subheadline).foregroundColor(Theme.textSecondary.opacity(0.7)).multilineTextAlignment(.center).padding(.horizontal, 40)
        }
    }
}
