//
//  ContentView.swift
//  NegotiateX
//
//  Created by Muhammad Bin Sohail on 10/20/24.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedPersona: String = "The Strategist"
    @Environment(\.colorScheme) var colorScheme

    let personas = [
        ("The Diplomat", "Nelson Mandela", "Bridging divides with empathy"),
        ("The Strategist", "Sun Tzu", "Winning without fighting"),
        ("The Dealmaker", "Harvey Specter", "Closing deals with precision and persuasion")
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("NegotiateX")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Choose your negotiation persona")
                    .font(.headline)
                    .foregroundColor(.secondary)

                VStack(spacing: 20) {
                    ForEach(personas, id: \.0) { persona, name, description in
                        PersonaCard(
                            persona: persona,
                            name: name,
                            description: description,
                            isSelected: selectedPersona == persona,
                            action: { selectedPersona = persona }
                        )
                    }
                }

                NavigationLink(destination: SimulationView(persona: selectedPersona)) {
                    Text("Start Simulation")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(10)
                }
                .padding(.top)
            }
            .padding()
            .background(colorScheme == .dark ? Color.black : Color.white)
            .navigationBarHidden(true)
        }
    }
}

struct PersonaCard: View {
    let persona: String
    let name: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            HStack {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())

                VStack(alignment: .leading) {
                    Text(name)
                        .font(.headline)
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding()
            .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var imageName: String {
        switch persona {
        case "The Diplomat":
            return "nelson"
        case "The Strategist":
            return "sun-tzu"
        case "The Dealmaker":
            return "harvey"
        default:
            return "placeholder" // Add a placeholder image to your asset catalog for this case
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
        HomeView().preferredColorScheme(.dark)
    }
}
