//
//  ContentView.swift
//  NegotiateX
//
//  Created by Muhammad Bin Sohail on 10/20/24.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedPersona: String = "The Strategist"
    
    var body: some View {
        NavigationView {   // Wrap everything in a NavigationView
            VStack {
                Text("Welcome to NegotiateX")
                    .font(.title)
                Text("Please select your persona.")
                    .padding(.top)
                
                // Persona Picker
                Picker("Persona", selection: $selectedPersona) {
                    Text("The Diplomat").tag("The Diplomat")
                    Text("The Strategist").tag("The Strategist")
                    Text("The Dealmaker").tag("The Dealmaker")
                }
                .pickerStyle(SegmentedPickerStyle()) // Use segmented picker for a better UI
                .padding()
                
                // NavigationLink to SimulationView
                NavigationLink(destination: SimulationView(persona: selectedPersona)) {
                    Text("Start Simulation")
                        .font(.title2)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top)
                
                Spacer()
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
}
