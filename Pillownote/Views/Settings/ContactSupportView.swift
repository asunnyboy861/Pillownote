import SwiftUI

struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss

    enum Subject: String, CaseIterable, Identifiable {
        case general = "General"
        case feature = "Feature Suggestion"
        case bug = "Bug Report"
        case usage = "Usage Question"
        case performance = "Performance Issue"
        case ui = "UI Improvement"
        case other = "Other"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .general: return "bubble.left.fill"
            case .feature: return "lightbulb.fill"
            case .bug: return "ant.fill"
            case .usage: return "questionmark.circle.fill"
            case .performance: return "gauge.with.dots.needle.67percent"
            case .ui: return "paintpalette.fill"
            case .other: return "ellipsis.circle.fill"
            }
        }
    }

    @State private var subject: Subject = .general
    @State private var customSubject = ""
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var result: SubmissionResult?

    enum SubmissionResult {
        case success, failure(String)
    }

    private var emailValid: Bool {
        email.contains("@") && email.contains(".") && email.count > 5
    }
    private var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        emailValid &&
        !message.trimmingCharacters(in: .whitespaces).isEmpty &&
        (subject != .other || !customSubject.trimmingCharacters(in: .whitespaces).isEmpty) &&
        !isSubmitting
    }
    private var messageLimit: Int { 1000 }

    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    subjectGrid
                    if subject == .other {
                        TextField("Tell us the topic…", text: $customSubject)
                            .padding(12)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Name").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                        TextField("Your name", text: $name)
                            .textContentType(.name)
                            .padding(12)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                        TextField("yourname@example.com", text: $email)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .autocorrectionDisabled()
                            .padding(12)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        if !email.isEmpty && !emailValid {
                            Text("Please enter a valid email address.")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Message").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                        TextEditor(text: $message)
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .onChange(of: message) { _, newValue in
                                if newValue.count > messageLimit {
                                    message = String(newValue.prefix(messageLimit))
                                }
                            }
                        Text("\(message.count) / \(messageLimit)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    Button {
                        submit()
                    } label: {
                        HStack {
                            if isSubmitting {
                                ProgressView().tint(.white)
                            } else {
                                Text("Submit")
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(!canSubmit)
                    Text("We only use your email to respond to this feedback.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)

                    if let result {
                        switch result {
                        case .success:
                            Label("Thank you! Your feedback has been sent.", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(Theme.sage)
                                .font(.subheadline.weight(.medium))
                        case .failure(let reason):
                            Label(reason, systemImage: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                                .font(.subheadline)
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: 640)
                .frame(maxWidth: .infinity)
            }
            .background(Theme.cream)
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var subjectGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What's it about?")
                .font(.subheadline.weight(.semibold))
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Subject.allCases) { option in
                    subjectTile(option)
                }
            }
        }
    }

    private func subjectTile(_ option: Subject) -> some View {
        let isSelected = subject == option
        return Button {
            subject = option
        } label: {
            VStack(spacing: 6) {
                Image(systemName: option.icon)
                    .font(.title3)
                Text(option.rawValue)
                    .font(.caption.weight(.medium))
                    .multilineTextAlignment(.center)
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isSelected ? Theme.coral : Color(uiColor: .secondarySystemBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .scaleEffect(isSelected ? 1.02 : 1)
            .animation(.spring(duration: 0.3), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(option.rawValue)\(isSelected ? ", selected" : "")")
    }

    private func submit() {
        isSubmitting = true
        let finalSubject = subject == .other ? customSubject : subject.rawValue
        let request = FeedbackRequest(
            name: name.trimmingCharacters(in: .whitespaces),
            email: email.trimmingCharacters(in: .whitespaces),
            subject: finalSubject,
            message: message.trimmingCharacters(in: .whitespaces),
            app_name: "Pillownote"
        )
        Task {
            do {
                guard let url = URL(string: "https://feedback-board.iocompile67692.workers.dev/api/feedback") else {
                    throw URLError(.badURL)
                }
                var urlRequest = URLRequest(url: url, timeoutInterval: 15)
                urlRequest.httpMethod = "POST"
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = try JSONEncoder().encode(request)
                let (_, response) = try await URLSession.shared.data(for: urlRequest)
                guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                await MainActor.run {
                    isSubmitting = false
                    result = .success
                    name = ""
                    email = ""
                    message = ""
                    customSubject = ""
                    subject = .general
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    result = .failure("Something went wrong. Please try again.")
                }
            }
        }
    }
}

struct FeedbackRequest: Codable {
    let name: String
    let email: String
    let subject: String
    let message: String
    let app_name: String
}
