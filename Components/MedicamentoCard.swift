//
//  MedicamentoCard.swift
//  MediTracker
//
//  Created by πcanmar on 25/11/25.
//


import SwiftUI

struct MedicamentoCard: View {
    // Esse card precisa receber um remédio para funcionar
    let medicamento: Medicamento
    
    var body: some View {
        HStack {
            // Ícone de pílula
            Image(systemName: "pills.fill")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding()
                .background(Color.mint) // Verde menta
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(medicamento.nome)
                    .font(.headline)
                
                Text(medicamento.dosagem)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Hora formatada
            Text(medicamento.horario, style: .time)
                .font(.caption)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
        .padding(.vertical, 5)
    }
}