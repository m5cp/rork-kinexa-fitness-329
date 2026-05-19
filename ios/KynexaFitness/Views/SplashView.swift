import SwiftUI

struct SplashView: View {
    var onFinished: () -> Void

    @State private var iconScale: Double = 0.6
    @State private var iconOpacity: Double = 0
    @State private var iconBlur: Double = 20
    @State private var iconGlowPulse: Double = 0.4
    @State private var ringScales: [Double] = [0.3, 0.2, 0.15]
    @State private var ringOpacities: [Double] = [0, 0, 0]
    @State private var ringRotations: [Double] = [-90, 60, -45]
    @State private var titleLetterOpacities: [Double] = Array(repeating: 0, count: 15)
    @State private var titleLetterOffsets: [Double] = Array(repeating: 30, count: 15)
    @State private var subtitleOpacity: Double = 0
    @State private var subtitleBlur: Double = 10
    @State private var lineWidth: Double = 0
    @State private var lineOpacity: Double = 0
    @State private var shimmerX: Double = -300
    @State private var exitScale: Double = 1.0
    @State private var exitOpacity: Double = 1.0

    private let titleText = "KYNEXA FIT"
    private let gold = Color(red: 0.90, green: 0.74, blue: 0.28)

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            RadialGradient(
                colors: [
                    gold.opacity(0.10 * iconGlowPulse),
                    Color.clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 320
            )
            .ignoresSafeArea()

            centralContent
        }
        .scaleEffect(exitScale)
        .opacity(exitOpacity)
        .ignoresSafeArea()
        .onAppear { runCinematicSequence() }
    }

    private var centralContent: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [
                                    gold.opacity(0.35 - Double(i) * 0.08),
                                    Color.white.opacity(0.15),
                                    Color.clear,
                                    gold.opacity(0.25 - Double(i) * 0.06),
                                    gold.opacity(0.35 - Double(i) * 0.08)
                                ],
                                center: .center
                            ),
                            lineWidth: 1.2 - Double(i) * 0.25
                        )
                        .frame(width: 180 + Double(i) * 50, height: 180 + Double(i) * 50)
                        .scaleEffect(ringScales[i])
                        .opacity(ringOpacities[i])
                        .rotationEffect(.degrees(ringRotations[i]))
                }

                Image("AppLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 180, height: 180)
                    .mask {
                        RadialGradient(
                            colors: [
                                .black,
                                .black,
                                .black.opacity(0.85),
                                .clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 100
                        )
                    }
                    .shadow(color: gold.opacity(iconGlowPulse * 0.6), radius: 40)
                    .shadow(color: .white.opacity(iconGlowPulse * 0.15), radius: 60)
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)
                    .blur(radius: iconBlur)
            }

            Spacer().frame(height: 48)

            VStack(spacing: 14) {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.clear, gold.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: lineWidth, height: 1)
                    Rectangle()
                        .fill(gold)
                        .frame(width: 4, height: 4)
                        .clipShape(Circle())
                        .opacity(lineOpacity)
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [gold.opacity(0.6), Color.clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: lineWidth, height: 1)
                }
                .frame(height: 4)

                Text("RISE BEFORE THE SUN")
                    .font(.system(size: 12, weight: .medium, design: .default))
                    .tracking(6)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white.opacity(0.85), .white.opacity(0.55)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(subtitleOpacity)
                    .blur(radius: subtitleBlur)
            }

            Spacer()
            Spacer()
        }
    }

    private func runCinematicSequence() {
        withAnimation(.spring(response: 0.9, dampingFraction: 0.6).delay(0.2)) {
            iconScale = 1.0
            iconOpacity = 1.0
            iconBlur = 0
        }

        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true).delay(1.0)) {
            iconGlowPulse = 1.0
        }

        for i in 0..<3 {
            let delay = 0.6 + Double(i) * 0.15
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(delay)) {
                ringScales[i] = 1.0
                ringOpacities[i] = 1.0
            }
            withAnimation(.linear(duration: Double(14 + i * 8)).repeatForever(autoreverses: false).delay(delay)) {
                ringRotations[i] += (i % 2 == 0 ? 360 : -360)
            }
        }

        for i in 0..<titleText.count {
            let delay = 1.4 + Double(i) * 0.05
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(delay)) {
                titleLetterOpacities[i] = 1.0
                titleLetterOffsets[i] = 0
            }
        }

        withAnimation(.easeOut(duration: 0.7).delay(2.3)) {
            lineWidth = 60
            lineOpacity = 1.0
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(2.6)) {
            subtitleOpacity = 1.0
            subtitleBlur = 0
        }

        withAnimation(.easeInOut(duration: 1.2).delay(2.9)) {
            shimmerX = 300
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.2) {
            withAnimation(.easeInOut(duration: 0.6)) {
                exitScale = 1.08
                exitOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                onFinished()
            }
        }
    }
}
