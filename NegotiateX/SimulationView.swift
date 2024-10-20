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

    let scenarios = [
        "Salary Negotiation", "Contract Dispute", "Partnership Terms", "Workplace Conflict",
    ]
    var persona: String

    var body: some View {
        VStack(spacing: 0) {
            topBar

            if selectedScenario == nil {
                scenarioSelection
            } else {
                chatInterface
            }

            bottomBar
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
            .help(
                isUsingInternet
                    ? "You are using Llama 3.2 90B online with Internet"
                    : "You are using Llama 3.2 1B locally without Internet")

            Image(systemName: personaIcon)
                .resizable()
                .frame(width: 20, height: 20)
            Text("Persona: \(persona)")
                .font(.headline)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }

    private var scenarioSelection: some View {
        ScrollView {
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

    private var bottomBar: some View {
        HStack {
            Button(action: {
                selectedScenario = nil
                chatMessages.removeAll()
            }) {
                Image(systemName: "arrow.left")
                Text("Back")
            }

            Spacer()

            Button(action: {
                if isUsingInternet {
                    uploadedFiles.append("File \(uploadedFiles.count + 1)")
                } else {
                    showingAlert = true
                }
            }) {
                Image(systemName: "paperclip")
                Text("Upload File")
            }

            if !uploadedFiles.isEmpty {
                Menu {
                    ForEach(uploadedFiles, id: \.self) { file in
                        Button(action: {
                            if let index = uploadedFiles.firstIndex(of: file) {
                                uploadedFiles.remove(at: index)
                            }
                        }) {
                            Text(file)
                            Image(systemName: "xmark.circle.fill")
                        }
                    }
                } label: {
                    Image(systemName: "doc.fill")
                    Text("\(uploadedFiles.count)")
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }

    private var personaIcon: String {
        switch persona {
        case "The Diplomat":
            return "globe"
        case "The Strategist":
            return "chart.bar"
        default:
            return "person.fill"
        }
    }

    private func sendMessage() {
        guard !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let message = ChatMessage(content: newMessage, isUser: true)
        chatMessages.append(message)
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
