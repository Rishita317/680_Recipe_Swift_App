import SwiftUI

struct CookingModeView: View {
    let steps: [RecipeStep]
    @Environment(\.dismiss) var dismiss
    @State private var currentStep = 0
    @State private var showConfetti = false
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

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
        }
    }

    // MARK: - Confetti Helpers

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
