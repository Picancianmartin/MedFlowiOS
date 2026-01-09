import SwiftUI
import SwiftData

struct EditarMedicamentoView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    // O objeto original
    let medicamento: Medicamento
    
    // VARIÁVEIS TEMPORÁRIAS (Edição Segura)
    // Usamos @State para não mexer no banco enquanto digita
    @State private var nomeEditado: String = ""
    @State private var dosagemEditada: String = ""
    @State private var horarioEditado: Date = Date()
    @State private var notasEditadas: String = ""
    @State private var duracaoEditada: Int = 0
    
    // Controle de segurança (reaproveitando a lógica)
    @State private var intervaloHoras: Int = 0
    @State private var limiteSeguranca: Int = 0
    
    var body: some View {
        Form {
            Section(header: Text("Informações")) {
                            VStack(alignment: .leading, spacing: 4) {
                                TextField("Nome do Medicamento", text: $nomeEditado)
                                
                                // --- AQUI ESTÁ A INFORMAÇÃO VISUAL ---
                                if !medicamento.sintomas.isEmpty {
                                    Text(medicamento.sintomas)
                                        .font(.caption)
                                        .foregroundColor(.gray)   // Cinza Claro
                                        .padding(.leading, 2)
                                }
                            }
                TextField("Dosagem", text: $dosagemEditada)
            }
            
            Section(header: Text("Horário e Duração")) {
                // Agora o DatePicker mexe na variável temporária, não no banco
                DatePicker("Próxima dose", selection: $horarioEditado, displayedComponents: [.date, .hourAndMinute])
                
                // Se quiser permitir editar a duração também
                Stepper(value: $duracaoEditada, in: 0...30) {
                    HStack {
                        Text("Duração:")
                        Spacer()
                        if duracaoEditada == 0 {
                            Text("Uso Contínuo").foregroundColor(.gray)
                        } else {
                            Text(duracaoEditada == 1 ? "1 dia" : "\(duracaoEditada) dias")
                                .bold().foregroundColor(Theme.primary)
                        }
                    }
                }
            }
            
            Section(header: Text("Anotações")) {
                TextEditor(text: $notasEditadas)
                    .frame(height: 100)
            }
            
            Section {
                Button(action: salvarAlteracoes) {
                    Text("Salvar Alterações")
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .listRowBackground(Theme.primary)
                
                Button(action: excluirMedicamento) {
                    Text("Excluir Medicamento")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("Editar")
        .navigationBarTitleDisplayMode(.inline)
        // CARREGAR DADOS AO ABRIR A TELA
        .onAppear {
            carregarDados()
        }
    }
    
    func carregarDados() {
        // Copia os dados do Banco para as Variáveis Temporárias
        nomeEditado = medicamento.nome
        dosagemEditada = medicamento.dosagem
        horarioEditado = medicamento.horario
        notasEditadas = medicamento.notas
        duracaoEditada = medicamento.duracaoDias ?? 0
    }
    
    func salvarAlteracoes() {
        // 1. Atualiza o objeto do banco com os novos valores
        medicamento.nome = nomeEditado
        medicamento.dosagem = dosagemEditada
        medicamento.horario = horarioEditado
        medicamento.notas = notasEditadas
        medicamento.duracaoDias = duracaoEditada
        
        // 2. Re-agenda as notificações (Cancela a velha e cria a nova)
        GerenciadorNotificacao.instance.cancelarNotificacao(idRemedio: medicamento.idUnico.uuidString)
        GerenciadorNotificacao.instance.agendarNotificacao(para: medicamento)
        
        // 3. Fecha a tela
        dismiss()
    }
    
    func excluirMedicamento() {
            // 1. Pega o ID da família desse remédio
            let idFamilia = medicamento.idTratamento
            
            do {
                // 2. Busca no banco TODAS as doses com esse mesmo ID
                // (Isso usa o Predicate do SwiftData)
                let descriptor = FetchDescriptor<Medicamento>(
                    predicate: #Predicate { $0.idTratamento == idFamilia }
                )
                let familiaInteira = try modelContext.fetch(descriptor)
                
                // 3. Varre a lista apagando um por um e cancelando notificações
                for parente in familiaInteira {
                    GerenciadorNotificacao.instance.cancelarNotificacao(idRemedio: parente.idUnico.uuidString)
                    modelContext.delete(parente)
                }
                
                print("Tratamento completo excluído com sucesso!")
                
            } catch {
                print("Erro ao buscar família do remédio: \(error)")
                // Se der erro, apaga pelo menos esse que tá na tela
                modelContext.delete(medicamento)
            }
            
            dismiss()
        }
}
