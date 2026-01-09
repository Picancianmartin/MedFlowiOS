import Foundation
import SwiftData

@Model
final class Medicamento {
    var idUnico: UUID = UUID()
    var idTratamento: UUID
    var nome: String
    var dosagem: String
    var horario: Date
    var notas: String
    var estaConcluido: Bool = false
    var sintomas: String
    
    // NOVO CAMPO: Se for 0 ou nil, é uso contínuo
    var duracaoDias: Int?
    
    init(nome: String, dosagem: String, horario: Date, notas: String = "", duracaoDias: Int? = nil, idTratamento: UUID = UUID(), sintomas: String) {
        self.idTratamento = idTratamento
        self.nome = nome
        self.dosagem = dosagem
        self.horario = horario
        self.notas = notas
        self.duracaoDias = duracaoDias
        self.sintomas = sintomas
    }
}
