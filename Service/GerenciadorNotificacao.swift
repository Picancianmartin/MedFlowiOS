import Foundation
import UserNotifications

class GerenciadorNotificacao: NSObject, UNUserNotificationCenterDelegate {
    
    static let instance = GerenciadorNotificacao()
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func pedirPermissao() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted { print("Permissão concedida! ✅") }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list])
    }
    
    // Agora a função é simples: 1 Remédio = 1 Notificação
    func agendarNotificacao(para remedio: Medicamento) {
        let conteudo = UNMutableNotificationContent()
        conteudo.title = "Hora do Remédio 💊"
        conteudo.body = "Tomar \(remedio.dosagem) de \(remedio.nome)"
        conteudo.sound = .default
        
        let componentes = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: remedio.horario)
        
        // LÓGICA SIMPLIFICADA
        // Se tem duração (dias > 0), o alarme toca uma vez naquela data específica (repeats: false)
        // Se é uso contínuo (dias == 0), o alarme repete todo dia naquele horário (repeats: true)
        
        let repete = (remedio.duracaoDias == 0)
        
        // Se for contínuo, ignoramos dia/mês/ano e usamos só hora/minuto para repetir sempre
        let gatilhoComponentes = repete ? Calendar.current.dateComponents([.hour, .minute], from: remedio.horario) : componentes
        
        let gatilho = UNCalendarNotificationTrigger(dateMatching: gatilhoComponentes, repeats: repete)
        
        let pedido = UNNotificationRequest(
            identifier: remedio.idUnico.uuidString, // Usa o ID do próprio objeto
            content: conteudo,
            trigger: gatilho
        )
        
        UNUserNotificationCenter.current().add(pedido)
        print("Alarme agendado para \(remedio.nome) às \(remedio.horario.formatted()) (Repete: \(repete))")
    }
    
    func cancelarNotificacao(idRemedio: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [idRemedio])
    }
}
