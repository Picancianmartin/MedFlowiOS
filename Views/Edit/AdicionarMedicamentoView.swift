import SwiftUI
import SwiftData

struct AdicionarMedicamentoView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var nome = ""
    @State private var dosagem = ""
    @State private var horario = Date()
    @State private var notas = ""
    @State private var intervaloHoras: Int = 0
    @State private var duracaoDias: Int = 0 // 0 = Uso Contínuo
    
    // Variável para armazenar o sintoma escolhido
    @State private var indicacaoSelecionada = ""
    
    // Controle de Sugestões e Segurança
    @State private var limiteSeguranca: Int = 0
    @State private var sugestoes: [BulaInteligente] = []
    @State private var mostrandoSugestoes = false
    
    var ehPerigoso: Bool {
        return limiteSeguranca > 0 && intervaloHoras > 0 && intervaloHoras < limiteSeguranca
    }
    
    var body: some View {
        NavigationView {
            Form {
                // SEÇÃO 1: NOME E BUSCA
                Section(header: Text("Qual o medicamento?")) {
                    ZStack(alignment: .leading) {
                        TextField("Nome (ex: Amoxicilina)", text: $nome)
                            .onChange(of: nome) { _, newValue in
                                sugestoes = MedicamentoService.shared.buscar(termo: newValue)
                                mostrandoSugestoes = !sugestoes.isEmpty
                                if newValue.isEmpty { limiteSeguranca = 0; indicacaoSelecionada = "" }
                            }
                        if nome.isEmpty { HStack { Spacer(); Image(systemName: "magnifyingglass").foregroundColor(.gray) } }
                    }
                    
                    if mostrandoSugestoes {
                        ForEach(sugestoes) { bula in
                            Button(action: { selecionarSugestao(bula) }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(bula.nome)
                                        .font(.headline)
                                        .foregroundColor(Theme.primary)
                                    
                                    // Mostra o sintoma corretamente
                                    Text(bula.sintomas.joined(separator: ","))
                                        .font(.system(size: 14))
                                        .italic()
                                        .foregroundColor(.gray)
                                    
                                    HStack {
                                        Text(bula.dosagem)
                                        Spacer()
                                        if bula.minimo_horas > 0 {
                                            Text("Mín: \(bula.minimo_horas)h")
                                                .font(.caption)
                                                .bold()
                                                .foregroundColor(.orange)
                                        }
                                    }
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                
                // SEÇÃO 2: ESQUEMA
                Section(header: Text("Esquema de Uso")) {
                    TextField("Dosagem", text: $dosagem)
                    
                    if !indicacaoSelecionada.isEmpty {
                        Text("Indicado para: \(indicacaoSelecionada)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    DatePicker("Início", selection: $horario, displayedComponents: .hourAndMinute)
                    
                    VStack(alignment: .leading) {
                        Stepper(value: $intervaloHoras, in: 0...24) {
                            HStack {
                                Text("Intervalo:")
                                Spacer()
                                Text(intervaloHoras > 0 ? "\(intervaloHoras)h" : "1x ao dia")
                                    .bold()
                                    .foregroundColor(ehPerigoso ? .red : Theme.primary)
                            }
                        }
                        
                        if ehPerigoso {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                VStack(alignment: .leading) {
                                    Text("Intervalo Contraindicado!")
                                        .bold()
                                    Text("A bula indica no mínimo \(limiteSeguranca) horas entre as doses.")
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.vertical, 4)
                        }
                    }
                    
                    Stepper(value: $duracaoDias, in: 0...30) {
                        HStack {
                            Text("Duração:")
                            Spacer()
                            if duracaoDias == 0 {
                                Text("Uso Contínuo").foregroundColor(.gray)
                            } else {
                                Text(duracaoDias == 1 ? "1 dia" : "\(duracaoDias) dias")
                                    .bold().foregroundColor(Theme.primary)
                            }
                        }
                    }
                    
                    if duracaoDias > 0 {
                        HStack {
                            Image(systemName: "flag.checkered").foregroundColor(Theme.success)
                            Text("Termina em: ")
                            if let fim = Calendar.current.date(byAdding: .day, value: duracaoDias, to: horario) {
                                Text(fim, format: .dateTime.day().month())
                                    .bold()
                            }
                        }
                        .font(.caption).foregroundColor(.gray)
                    }
                }
                
                if intervaloHoras > 0 {
                                    Section(header: Text("Previsão de Horários")) {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 12) {
                                                // Mostra até 5 horários futuros para conferência
                                                let loops = max(1, min(5, 24 / intervaloHoras))
                                                ForEach(1...loops, id: \.self) { index in
                                                    if let next = Calendar.current.date(byAdding: .hour, value: intervaloHoras * index, to: horario) {
                                                        VStack {
                                                            Text(next, style: .time)
                                                                .bold()
                                                                .foregroundColor(Theme.primary)
                                                            Text("+ \(intervaloHoras * index)h")
                                                                .font(.caption2)
                                                                .foregroundColor(.gray)
                                                        }
                                                        .padding(.horizontal, 12)
                                                        .padding(.vertical, 8)
                                                        .background(Theme.background)
                                                        .cornerRadius(8)
                                                    }
                                                }
                                            }
                                            .padding(.vertical, 4)
                                        }
                                    }
                                }
                
                // BOTÃO SALVAR
                Button(action: salvar) {
                    HStack {
                        if ehPerigoso { Image(systemName: "lock.fill") }
                        Text("Criar Tratamento").bold()
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                }
                .disabled(nome.isEmpty || ehPerigoso)
                .listRowBackground((nome.isEmpty || ehPerigoso) ? Color.gray : Theme.success)
            }
            .navigationTitle("Novo Tratamento")
            .navigationBarItems(leading: Button("Cancelar") { dismiss() })
        }
    }
    
    // --- FUNÇÕES ---
    
    func selecionarSugestao(_ bula: BulaInteligente) {
        nome = bula.nome
        dosagem = bula.dosagem
        intervaloHoras = bula.intervalo
        duracaoDias = bula.duracao_dias ?? 0
        limiteSeguranca = bula.minimo_horas
        indicacaoSelecionada = bula.sintomas.joined(separator: ",")
        mostrandoSugestoes = false
    }
    
    func salvar() {
        let intervalo = intervaloHoras > 0 ? intervaloHoras : 24
        let idDoGrupo = UUID()
        
        // CASO 1: TRATAMENTO COM FIM
        if duracaoDias > 0 {
            let dosesPorDia = 24 / intervalo
            let totalDoses = dosesPorDia * duracaoDias
            
            print("Gerando \(totalDoses) doses no banco...")
            
            for i in 0..<totalDoses {
                if let dataDose = Calendar.current.date(byAdding: .hour, value: i * intervalo, to: horario) {
                    
                    let novaDose = Medicamento(
                        nome: nome,
                        dosagem: dosagem,
                        horario: dataDose,
                        notas: notas,
                        duracaoDias: duracaoDias,
                        idTratamento: idDoGrupo,
                        sintomas: indicacaoSelecionada
                                            )
                    modelContext.insert(novaDose)
                    GerenciadorNotificacao.instance.agendarNotificacao(para: novaDose)
                }
            }
        }
        // CASO 2: USO CONTÍNUO
        else {
            let dosesPorDia = max(1, 24 / intervalo)
            for i in 0..<dosesPorDia {
                if let dataDose = Calendar.current.date(byAdding: .hour, value: i * intervalo, to: horario) {
                    
                    let novaDose = Medicamento(
                        nome: nome,
                        dosagem: dosagem,
                        horario: dataDose,
                        notas: notas,
                        duracaoDias: 0,
                        idTratamento: idDoGrupo,
                        sintomas: indicacaoSelecionada
                        
                    )
                    modelContext.insert(novaDose)
                    GerenciadorNotificacao.instance.agendarNotificacao(para: novaDose)
                }
            }
        }
        dismiss()
    }
}
