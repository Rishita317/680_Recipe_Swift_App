import SwiftUI
import AVFoundation

struct CookingModeView: View {
    let steps: [RecipeStep]
    @Environment(\.dismiss) var dismiss
    @State private var currentStep = 0
    @State private var showConfetti = false
    @State private var particles: [ConfettiParticle] = []

    @State private var timeElapsed: Int = 0
    @State private var timerRunning = true
    @State private var timer: Timer?

    private let synthesizer = AVSpeechSynthesizer()

    var formattedTime: String {
        let minutes = timeElapsed / 60
        let seconds = timeElapsed % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Time Tracker Bar
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "timer")
                            .foregroundColor(.gray)
                        Text("Time Spent")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(formattedTime)
                            .font(.system(.body, design: .monospaced).bold())
                            .foregroundColor(.blue)
                    }

                    Spacer()

                    Button(action: toggleTimer) {
                        HStack(spacing: 4) {
                            Image(systemName: timerRunning ? "pause.fill" : "play.fill")
                            Text(timerRunning ? "Pause" : "Resume")
                        }
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                        .shadow(radius: 1)
                )
                .padding([.top, .horizontal])

                TabView(selection: $currentStep) {
                    ForEach(steps.indices, id: \.self) { i in
                        VStack(spacing: 30) {
                            Spacer()

                            Text("Step \(i + 1) of \(steps.count)")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            Text(steps[i].stepDesc)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .padding()

                            Button(action: {
                                speakStep(steps[i].stepDesc)
                            }) {
                                Label("Read Aloud", systemImage: "speaker.wave.2.fill")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(8)
                            }

                            Spacer()

                            if i == steps.count - 1 {
                                Button("🎉 Done Cooking!") {
                                    withAnimation {
                                        showConfetti = true
                                        spawnConfetti()
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        showConfetti = false
                                        dismiss()
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .padding(.horizontal)
                                .padding(.bottom, 40)
                            }
                        }
                        .padding()
                        .tag(i)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            }

            if showConfetti {
                GeometryReader { geo in
                    ZStack {
                        ForEach(particles) { particle in
                            Circle()
                                .fill(particle.color)
                                .frame(width: particle.size, height: particle.size)
                                .position(particle.position)
                                .opacity(particle.opacity)
                        }
                    }
                    .onAppear {
                        animateParticles(in: geo.size)
                    }
                }
                .ignoresSafeArea()
            }
        }
        .navigationTitle("Cooking Mode")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.systemBlue
            UIPageControl.appearance().pageIndicatorTintColor = UIColor.systemGray4
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    // MARK: - Timer Logic
    func startTimer() {
        timerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeElapsed += 1
        }
    }

    func toggleTimer() {
        if timerRunning {
            timer?.invalidate()
        } else {
            startTimer()
        }
        timerRunning.toggle()
    }

    // MARK: - Text-to-Speech
    func speakStep(_ text: String) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }

    // MARK: - Confetti
    func spawnConfetti() {
        particles = (0..<80).map { _ in
            ConfettiParticle(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: -50 ... -10),
                color: [.red, .yellow, .green, .blue, .purple, .pink].randomElement()!,
                size: CGFloat.random(in: 6...10)
            )
        }
    }

    func animateParticles(in size: CGSize) {
        for index in particles.indices {
            let duration = Double.random(in: 2.0...3.5)
            withAnimation(.easeIn(duration: duration)) {
                particles[index].position.y = size.height + 50
                particles[index].opacity = 0
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var color: Color
    var size: CGFloat
    var position: CGPoint
    var opacity: Double = 1

    init(x: CGFloat, y: CGFloat, color: Color, size: CGFloat) {
        self.position = CGPoint(x: x, y: y)
        self.color = color
        self.size = size
    }
}
