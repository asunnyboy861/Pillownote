import SwiftUI
import SwiftData
import PhotosUI
import Speech

struct NoteComposerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var profiles: [CoupleProfile]
    @Query(sort: \PillowNote.createdUTC, order: .reverse) private var existingNotes: [PillowNote]
    @StateObject private var purchaseManager = PurchaseManager.shared
    var replyingTo: Question?

    @State private var kind: NoteKind = .text
    @State private var bodyText = ""
    @State private var photoItem: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var voiceURL: URL?
    @State private var voiceDuration: TimeInterval = 0
    @State private var transcript = ""
    @State private var isTranscribing = false
    @State private var transcriptPermissionDenied = false
    @StateObject private var recorder = VoiceRecorder()
    @StateObject private var speech = SpeechService()

    private var profile: CoupleProfile? { profiles.first }
    private var isPlus: Bool { purchaseManager.isPremium }
    private var freeNoteTodayUsed: Bool {
        guard !isPlus else { return false }
        let calendar = Calendar.current
        return existingNotes.contains { !$0.isIncoming && calendar.isDateInToday($0.createdUTC) }
    }
    private var canSend: Bool {
        guard !freeNoteTodayUsed || replyingTo != nil else { return false }
        switch kind {
        case .text: return !bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .photo: return photoData != nil
        case .voice: return voiceURL != nil
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    kindPicker
                    if freeNoteTodayUsed && replyingTo == nil {
                        freeLimitCard
                    }
                    editor
                    scheduleInfo
                }
                .padding(20)
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .background(Theme.cream)
            .navigationTitle(replyingTo == nil ? "New Pillow Note" : "Reply Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") { send() }
                        .disabled(!canSend)
                }
            }
        }
    }

    private var kindPicker: some View {
        Picker("Type", selection: $kind) {
            Label("Letter", systemImage: "envelope.fill").tag(NoteKind.text)
            Label(isPlus ? "Voice" : "Voice+", systemImage: "waveform").tag(NoteKind.voice)
            Label(isPlus ? "Photo" : "Photo+", systemImage: "photo.fill").tag(NoteKind.photo)
        }
        .pickerStyle(.segmented)
        .onChange(of: kind) { _, newValue in
            if !isPlus && newValue != .text {
                kind = .text
            }
        }
    }

    private var freeLimitCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("You've sent today's free note", systemImage: "lock.fill")
                .font(.subheadline.weight(.semibold))
            Text("Plus gives you unlimited notes — text, voice and photos. Your daily question stays free forever.")
                .font(.caption)
                .foregroundStyle(.secondary)
            NavigationLink {
                PaywallView()
            } label: {
                Text("See Plus")
            }
            .buttonStyle(.bordered)
        }
        .cozyCard()
    }

    @ViewBuilder
    private var editor: some View {
        switch kind {
        case .text:
            TextField("Write something for their pillow…", text: $bodyText, axis: .vertical)
                .lineLimit(4...10)
                .padding(14)
                .background(Theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        case .voice:
            voiceEditor
        case .photo:
            photoEditor
        }
    }

    private var voiceEditor: some View {
        VStack(spacing: 16) {
            Button {
                toggleRecording()
            } label: {
                ZStack {
                    Circle()
                        .fill(recorder.isRecording ? Theme.coral : Theme.cardBackground)
                        .frame(width: 88, height: 88)
                        .shadow(color: Theme.coral.opacity(recorder.isRecording ? 0.5 : 0), radius: 14)
                    Image(systemName: recorder.isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(recorder.isRecording ? .white : Theme.coral)
                }
            }
            .accessibilityLabel(recorder.isRecording ? "Stop recording" : "Start recording voice note")
            Text(recorder.isRecording ? String(format: "Recording… %d sec", Int(recorder.duration)) : "Hold a moment, speak your heart")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if voiceURL != nil {
                Text("Voice note ready (\(Int(voiceDuration))s)")
                    .font(.caption)
                    .foregroundStyle(Theme.sage)
            }
            if isTranscribing {
                ProgressView("Transcribing…")
            } else if !transcript.isEmpty {
                Text(transcript)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cozyCard()
            }
            if transcriptPermissionDenied {
                Text("Enable speech transcription in Settings to see text alongside your voice.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .cozyCard()
    }

    private var photoEditor: some View {
        VStack(spacing: 14) {
            if let data = photoData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
            }
            PhotosPicker(selection: $photoItem, matching: .images) {
                Label("Choose photo", systemImage: "photo.badge.plus")
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
        .cozyCard()
        .onChange(of: photoItem) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self) {
                    photoData = data
                }
            }
        }
    }

    private var scheduleInfo: some View {
        let unlock = NotificationService.unlockAtForPartner(partnerTZ: profile?.partnerTZ ?? "")
        return Label("Unlocks on their pillow at 7:00 AM their time (\(unlock.formatted(.dateTime.month(.abbreviated).day().hour().minute())))", systemImage: "clock.badge.checkmark")
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    private func toggleRecording() {
        if recorder.isRecording {
            recorder.stop()
            voiceURL = recorder.lastRecordingURL
            voiceDuration = recorder.duration
            transcribe()
        } else {
            voiceURL = nil
            transcript = ""
            _ = recorder.start()
        }
    }

    private func transcribe() {
        guard let url = voiceURL else { return }
        isTranscribing = true
        Task {
            let granted = await speech.requestPermissions()
            guard granted else {
                await MainActor.run {
                    isTranscribing = false
                    transcriptPermissionDenied = true
                }
                return
            }
            let text = await Self.transcribeFile(url: url)
            await MainActor.run {
                transcript = text
                isTranscribing = false
            }
        }
    }

    nonisolated private static func transcribeFile(url: URL) async -> String {
        await withCheckedContinuation { continuation in
            Task {
                let locale = Locale.current
                guard let recognizer = SFSpeechRecognizer(locale: locale) else {
                    continuation.resume(returning: "")
                    return
                }
                let request = SFSpeechURLRecognitionRequest(url: url)
                request.shouldReportPartialResults = false
                var finished = false
                recognizer.recognitionTask(with: request) { result, error in
                    if !finished, let result = result, result.isFinal {
                        finished = true
                        continuation.resume(returning: result.bestTranscription.formattedString)
                    } else if error != nil, !finished {
                        finished = true
                        continuation.resume(returning: "")
                    }
                }
            }
        }
    }

    private func send() {
        let unlockAt = replyingTo != nil ? Date().addingTimeInterval(10) : NotificationService.unlockAtForPartner(partnerTZ: profile?.partnerTZ ?? "")
        let note = PillowNote(
            kind: kind,
            bodyText: kind == .text ? bodyText : (transcript.isEmpty ? "" : transcript),
            transcript: kind == .voice ? transcript : nil,
            photoData: kind == .photo ? photoData : nil,
            voicePath: kind == .voice ? voiceURL?.path : nil,
            voiceDuration: kind == .voice ? voiceDuration : 0,
            unlockAt: unlockAt,
            isIncoming: false
        )
        if kind == .text {
            note.bodyEncrypted = CryptoService.encrypt(bodyText)
        }
        context.insert(note)
        try? context.save()
        NotificationService.scheduleNoteArrival(noteID: note.id, at: unlockAt.addingTimeInterval(2), senderName: profile?.partnerName ?? "")
        HapticService.heartbeat()
        WidgetUpdater.update(context: context)
        dismiss()
    }
}
