import Foundation

// 1. A Struct preparada para ler o JSON
struct BulaInteligente: Identifiable, Codable {
    var id: UUID = UUID()
    let nome: String
    let dosagem: String
    let sintomas: [String]
    let intervalo: Int
    let minimo_horas: Int
    let duracao_dias: Int?
    
    // Mapeia os campos do JSON para o Swift
    enum CodingKeys: String, CodingKey {
        case nome, dosagem, sintomas, intervalo, minimo_horas, duracao_dias
    }
}

class MedicamentoService {
    static let shared = MedicamentoService()
    
    // Começa vazio
    var bancoDeBulas: [BulaInteligente] = []
    
    init() {
        carregarDadosDoJSON()
    }
    
    // 2. Lê o arquivo JSON
    private func carregarDadosDoJSON() {
        guard let url = Bundle.main.url(forResource: "medicamentos", withExtension: "json") else {
            print("⚠️ Arquivo medicamentos.json não encontrado.")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            bancoDeBulas = try JSONDecoder().decode([BulaInteligente].self, from: data)
            print("✅ Carreguei \(bancoDeBulas.count) bulas do JSON.")
        } catch {
            print("❌ Erro ao ler JSON: \(error)")
        }
    }
    
    // 3. Busca Otimizada
        func buscar(termo: String) -> [BulaInteligente] {
            if termo.isEmpty { return [] }
            
            // Limpa o termo digitado (sem acentos, minúsculo)
            let termoLimpo = termo
                .folding(options: .diacriticInsensitive, locale: .current)
                .lowercased()
            
            return bancoDeBulas.filter { bula in
                // 1. Verifica se bate com o NOME
                let nomeLimpo = bula.nome
                    .folding(options: .diacriticInsensitive, locale: .current)
                    .lowercased()
                
                if nomeLimpo.contains(termoLimpo) {
                    return true
                }
                
                // 2. Se não achou no nome, verifica na lista de SINTOMAS
                // Percorre cada sintoma da lista para ver se algum contém o termo
                let achouNosSintomas = bula.sintomas.contains { sintoma in
                    let sintomaLimpo = sintoma
                        .folding(options: .diacriticInsensitive, locale: .current)
                        .lowercased()
                    
                    return sintomaLimpo.contains(termoLimpo)
                }
                
                return achouNosSintomas
            }
        }
}
