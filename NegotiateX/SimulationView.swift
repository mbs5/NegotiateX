//
//  SimulationScreen.swift
//  NegotiateX
//
//  Created by Muhammad Bin Sohail on 10/20/24.
//

import SwiftUI

struct SimulationView: View {
    var persona: String
    
    var body: some View {
        
        VStack {
            Text("Simulation Screen!")
                .font(.headline)
            Text("Your chosen persona is \(persona). Begin negotiating")
        }
        
    }
}

#Preview {
    SimulationView(persona: "The Diplomat")
}
