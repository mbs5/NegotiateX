//
//  SimulationScreen.swift
//  NegotiateX
//
//  Created by Muhammad Bin Sohail on 10/20/24.
//

import SwiftUI

struct SimulationView: View {
    @State private var isUsingInternet = true
    @State private var showingAlert = false
    @State private var uploadedFiles: [String] = []
    @State private var selectedScenario: String?
    @State private var chatMessages: [ChatMessage] = []
    @State private var newMessage = ""
    @State private var showPersonaDropdown = false

    let scenarios = [
        "Salary Negotiation", "Contract Dispute", "Partnership Terms", "Workplace Conflict",
    ]
    @State var persona: String  // Changed from private to public

    // Add a public initializer
    public init(persona: String) {
        _persona = State(initialValue: persona)
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            if selectedScenario == nil {
                scenarioSelectionAndInput
            } else {
                chatInterface
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("No Internet Connection"),
                message: Text("Please turn on your Wi-Fi to upload files."),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var topBar: some View {
        HStack {
            Button(action: {
                selectedScenario = nil
                chatMessages.removeAll()
            }) {
                Image(systemName: "arrow.left")
                Text("Back")
            }

            Spacer()

            HStack {
                Circle()
                    .fill(isUsingInternet ? Color.green : Color.blue)
                    .frame(width: 10, height: 10)
                Text(isUsingInternet ? "Using Internet" : "Not Using Internet")
                    .font(.caption)
            }
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(20)

            Spacer()

            Menu {
                Button("Nelson Mandela - The Diplomat") { persona = "The Diplomat" }
                Button("Sun Tzu - The Strategist") { persona = "The Strategist" }
                Button("Harvey Specter - The Dealmaker") { persona = "The Dealmaker" }
            } label: {
                Image(systemName: personaIcon)
                    .resizable()
                    .frame(width: 20, height: 20)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }

    private var scenarioSelectionAndInput: some View {
        VStack {
            Spacer()

            Text("Here are some examples to choose from:")
                .font(.headline)
                .padding(.bottom)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                ForEach(scenarios, id: \.self) { scenario in
                    Button(action: {
                        selectedScenario = scenario
                    }) {
                        Text(scenario)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
            }
            .padding()

            Spacer()

            HStack {
                TextField("Type a scenario or message...", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                }
                .padding(.trailing)
            }
            .padding(.vertical)
        }
    }

    private var chatInterface: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(chatMessages) { message in
                        ChatBubble(message: message)
                    }
                }
                .padding()
            }

            HStack {
                TextField("Type a message...", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                }
                .padding(.trailing)
            }
            .padding(.vertical)
        }
    }

    private var personaIcon: String {
        switch persona {
        case "The Diplomat":
            return "globe"
        case "The Strategist":
            return "chart.bar"
        case "The Dealmaker":
            return "briefcase"
        default:
            return "person.fill"
        }
    }

    private func sendMessage() {
        guard !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        if selectedScenario == nil {
            selectedScenario = newMessage
        } else {
            let message = ChatMessage(content: newMessage, isUser: true)
            chatMessages.append(message)
        }
        newMessage = ""

        // Simulate AI response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let aiResponse = ChatMessage(content: "This is a simulated AI response.", isUser: false)
            chatMessages.append(aiResponse)
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
}

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            Text(message.content)
                .padding()
                .background(message.isUser ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            if !message.isUser { Spacer() }
        }
    }
}

struct SimulationView_Previews: PreviewProvider {
    static var previews: some View {
        SimulationView(persona: "The Diplomat")
    }
}
