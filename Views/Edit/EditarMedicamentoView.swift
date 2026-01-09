import SwiftUI
import SwiftData

struct EditarMedicamentoView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Bindable var medicamento: Medicamento
    
    var body: some View {
        Form {
            Section(header: Text("Detalhes")) {
                TextField("Nome do remédio", text: $medicamento.nome)
                TextField("Dosagem", text: $medicamento.dosagem)
            }
            
            Section(header: Text("Horário")) {
                DatePicker("Hora da dose", selection: $medicamento.horario, displayedComponents: .hourAndMinute)
            }
            
            Section(header: Text("Notas")) {
                TextEditor(text: $medicamento.notas)
                    .frame(height: 100)
            }
            
            Section {
                Button(action: {
                    GerenciadorNotificacao.instance.agendarNotificacao(para: medicamento)
                    dismiss()
                }) {
                    Text("Salvar Alterações")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.white)
                        .bold()
                }
                .listRowBackground(Theme.primary) // Agora vai funcionar porque criamos o Theme
            }
            
            Section {
                Button(role: .destructive, action: {
                    modelContext.delete(medicamento)
                    GerenciadorNotificacao.instance.cancelarNotificacao(idRemedio: medicamento.idUnico.uuidString)
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Excluir Medicamento")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("Editar Remédio")
        .navigationBarTitleDisplayMode(.inline)
    }
}
