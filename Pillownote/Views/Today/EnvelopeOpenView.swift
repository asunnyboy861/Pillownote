import SwiftUI
import SwiftData
import AVFoundation

struct EnvelopeOpenView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    var note: PillowNote
    @State private var torn = false
    @State private var player: AVAudioPlayer?

    private let reactions = ["❤️", "🥰", "😄", "🥲", "😮", "🔥"]

    var body: some View {
        VStack(spacing: 24) {
            if torn {
                openedContent
                    .transition(.opacity)
            } else {
                sealedContent
                    .transition(.opacity)
            }
        }
        .padding(24)
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.cream)
        .navigationTitle("Pillow Note")
        .navigationBarTitleDisplayMode(.inline)
        .gesture(
            DragGesture(minimumDistance: 40).onEnded { value in
                if value.translation.height < 0 { openNote() }
            }
        )
    }

    private var sealedContent: some View {
        VStack(spacing: 28) {
            Spacer()
            EnvelopeSealedView()
                .frame(width: 200, height: 150)
                .shadow(color: Theme.coral.opacity(0.4), radius: 20, y: 8)
            VStack(spacing: 8) {
                Text("From their pillow")
                    .font(.title3.weight(.semibold))
                Text("Swipe up to tear it open")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                openNote()
            } label: {
                Label("Open", systemImage: "envelope.open.fill")
            }
            .buttonStyle(PrimaryButtonStyle())
            .frame(maxWidth: 260)
            .padding(.bottom, 32)
        }
    }

    private var openedContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if note.kind == .photo, let data = note.photoData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                if note.kind == .voice {
                    voicePlayer
                }
                if !note.bodyText.isEmpty {
                    Text(note.bodyText)
                        .font(.system(.title3, design: .serif))
                }
                if let transcript = note.transcript, !transcript.isEmpty, note.kind == .voice {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Transcript")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(transcript)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .cozyCard()
                }
                if note.reaction == nil {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("How did it make you feel?")
                            .font(.subheadline.weight(.semibold))
                        HStack(spacing: 12) {
                            ForEach(reactions, id: \.self) { emoji in
                                Button {
                                    react(emoji)
                                } label: {
                                    Text(emoji)
                                        .font(.title2)
                                        .frame(width: 48, height: 48)
                                        .background(Color(uiColor: .tertiarySystemFill))
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("React with \(emoji)")
                            }
                        }
                    }
                    .cozyCard()
                } else {
                    Label("You reacted \(note.reaction!)", systemImage: "heart.fill")
                        .foregroundStyle(Theme.coral)
                        .font(.subheadline)
                }
            }
            .padding(.vertical, 12)
        }
    }

    private var voicePlayer: some View {
        HStack(spacing: 14) {
            Button {
                togglePlayback()
            } label: {
                Image(systemName: player?.isPlaying == true ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Theme.coral)
            }
            .accessibilityLabel(player?.isPlaying == true ? "Pause voice note" : "Play voice note")
            VStack(alignment: .leading) {
                Text("Voice note")
                    .font(.subheadline.weight(.semibold))
                Text(String(format: "%d sec", Int(note.voiceDuration)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .cozyCard()
    }

    private func openNote() {
        guard !torn else { return }
        withAnimation(.easeInOut(duration: 0.45)) {
            torn = true
        }
        note.openedAt = Date()
        try? context.save()
        HapticService.tearOpen()
        NotificationService.cancelNoteArrival(noteID: note.id)
    }

    private func react(_ emoji: String) {
        note.reaction = emoji
        try? context.save()
        HapticService.heartbeat()
    }

    private func togglePlayback() {
        if player?.isPlaying == true {
            player?.pause()
            return
        }
        if let path = note.voicePath, let audioPlayer = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: path)) {
            audioPlayer.play()
            player = audioPlayer
        }
    }
}
