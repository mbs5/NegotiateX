//
//  SimulationScreen.swift
//  NegotiateX
//
//  Created by Muhammad Bin Sohail on 10/20/24.
//

import PhotosUI
import SwiftUI

struct SimulationView: View {
    @State private var isUsingInternet = false
    @State private var uploadedFiles: [String] = []
    @State private var uploadedImages: [UIImage] = []
    @State private var selectedScenario: String?
    @State private var chatMessages: [ChatMessage] = []
    @State private var newMessage = ""
    @State private var showPersonaDropdown = false
    @State private var showImagePicker = false
    @State private var showFilePicker = false

    let scenarios = [
        "Salary Negotiation", "Contract Dispute", "Partnership Terms", "Workplace Conflict",
    ]
    @State var persona: String

    @Environment(\.colorScheme) var colorScheme

    public init(persona: String) {
        _persona = State(initialValue: persona)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if selectedScenario == nil {
                    scenarioSelectionAndInput
                } else {
                    chatInterface
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    internetStatusView
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    personaMenu
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $uploadedImages, isUsingInternet: $isUsingInternet)
        }
        .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.item]) { result in
            switch result {
            case .success(let url):
                uploadedFiles.append(url.lastPathComponent)
                isUsingInternet = true
            case .failure(let error):
                print("Error importing file: \(error.localizedDescription)")
            }
        }
    }

    private var personaMenu: some View {
        Menu {
            Button("Nelson Mandela - The Diplomat") { persona = "The Diplomat" }
            Button("Sun Tzu - The Strategist") { persona = "The Strategist" }
            Button("Harvey Specter - The Dealmaker") { persona = "The Dealmaker" }
        } label: {
            HStack {
                Image(systemName: personaIcon)
                Image(systemName: showPersonaDropdown ? "chevron.up" : "chevron.down")
            }
        }
    }

    private var internetStatusView: some View {
        HStack {
            Circle()
                .fill(isUsingInternet ? Color.green : Color.blue)
                .frame(width: 10, height: 10)
            Text(isUsingInternet ? "Using Internet" : "Not Using Internet")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(8)
        .background(Color(colorScheme == .dark ? .gray : .white).opacity(0.2))
        .cornerRadius(20)
        .help(
            isUsingInternet
                ? "You are using Llama 3.2 90B online with Internet"
                : "You are using Llama 3.2 1B locally without Internet")
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

            inputField
        }
    }

    private var inputField: some View {
        VStack {
            HStack {
                TextField("Type a scenario or message...", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                uploadButton

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                }
                .padding(.trailing)
            }

            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(uploadedImages.indices, id: \.self) { index in
                            Image(uiImage: uploadedImages[index])
                                .resizable()
                                .scaledToFit()
                                .frame(height: 40)
                                .cornerRadius(5)
                                .overlay(
                                    Button(action: { uploadedImages.remove(at: index) }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                    .offset(x: 15, y: -15),
                                    alignment: .topTrailing
                                )
                        }
                        ForEach(uploadedFiles, id: \.self) { file in
                            Text(file)
                                .padding(5)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(5)
                                .overlay(
                                    Button(action: { uploadedFiles.removeAll { $0 == file } }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                    .offset(x: 5, y: -5),
                                    alignment: .topTrailing
                                )
                        }
                    }
                }
            }
            .frame(height: uploadedImages.isEmpty && uploadedFiles.isEmpty ? 0 : 50)
        }
        .padding(.vertical)
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
        }
        let message = ChatMessage(content: newMessage, isUser: true)
        chatMessages.append(message)

        isUsingInternet = true

        aimlService.generateResponse(
            prompt: newMessage,
            scenario: selectedScenario ?? "General negotiation",
            persona: persona,
            images: uploadedImages
        ) { result in
            DispatchQueue.main.async {
                self.isUsingInternet = false

                switch result {
                case .success(let response):
                    let aiResponse = ChatMessage(content: response, isUser: false)
                    self.chatMessages.append(aiResponse)
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    let errorMessage =
                        (error as? AIMLError)?.errorDescription ?? error.localizedDescription
                    let errorChatMessage = ChatMessage(
                        content: "Error: \(errorMessage)", isUser: false)
                    self.chatMessages.append(errorChatMessage)
                }
            }
        }

        newMessage = ""
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
                            .background(Color(colorScheme == .dark ? .gray : .white).opacity(0.2))
                            .cornerRadius(10)
                    }
                }
            }
            .padding()

            Spacer()

            inputField
        }
    }

    private var uploadButton: some View {
        Menu {
            Button("Upload Photo") {
                showImagePicker = true
            }
            Button("Upload File") {
                showFilePicker = true
            }
        } label: {
            Image(systemName: "plus")
        }
    }

    private let aimlService = AIMLService(apiKey: Config.aimlApiKey)
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
}

struct ChatBubble: View {
    let message: ChatMessage
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            Text(message.content)
                .padding()
                .background(message.isUser ? Color.accentColor : Color.clear)
                .foregroundColor(message.isUser ? .white : (colorScheme == .dark ? .white : .black))
                .cornerRadius(10)
            if !message.isUser { Spacer() }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: [UIImage]
    @Binding var isUsingInternet: Bool

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.image.append(image)
                parent.isUsingInternet = true
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            if parent.image.isEmpty && parent.isUsingInternet {
                parent.isUsingInternet = false
            }
            picker.dismiss(animated: true)
        }
    }
}

struct SimulationView_Previews: PreviewProvider {
    static var previews: some View {
        SimulationView(persona: "The Diplomat")
    }
}
