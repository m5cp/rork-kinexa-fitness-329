import SwiftUI

struct SplashView: View {
    var onFinished: () -> Void

    @State private var phase: SplashPhase = .dark
    @State private var meshT: Float = 0.0
    @State private var orbOffsets: [CGSize] = Array(repeating: .zero, count: 6)
    @State private var orbOpacities: [Double] = Array(repeating: 0, count: 6)
    @State private var iconScale: Double = 0.0
    @State private var iconOpacity: Double = 0
    @State private var iconBlur: Double = 20
    @State private var iconPulse: Double = 1.0
    @State private var iconGlowPulse: Double = 0.7
    @State private var iconRotation3D: Double = 0
    @State private var iconYOffset: Double = 60
    @State private var ringScales: [Double] = [0.3, 0.2, 0.15]
    @State private var ringOpacities: [Double] = [0, 0, 0]
    @State private var ringRotations: [Double] = [-90, 60, -45]
    @State private var shockwaveScale: Double = 0.1
    @State private var shockwaveOpacity: Double = 0
    @State private var glowIntensity: Double = 0
    @State private var titleLetterOpacities: [Double] = Array(repeating: 0, count: 15)
    @State private var titleLetterOffsets: [Double] = Array(repeating: 30, count: 15)
    @State private var subtitleOpacity: Double = 0
    @State private var subtitleBlur: Double = 10
    @State private var lineWidth: Double = 0
    @State private var lineOpacity: Double = 0
    @State private var shimmerX: Double = -300
    @State private var ambientPulse: Double = 0.6
    @State private var exitScale: Double = 1.0
    @State private var exitOpacity: Double = 1.0
    @State private var verticalBeamOpacity: Double = 0
    @State private var verticalBeamOffset: Double = 200

    private let titleText = "KINEXA FIT"

    nonisolated private enum SplashPhase {
        case dark, reveal, hold, exit
    }

    var body: some View {
        ZStack {
            backgroundLayer
            orbField
            verticalLightBeam
            centralContent
        }
        .scaleEffect(exitScale)
        .opacity(exitOpacity)
        .ignoresSafeArea()
        .onAppear { runCinematicSequence() }
    }

    private var backgroundLayer: some View {
        ZStack {
            Color(hex: "#050807").ignoresSafeArea()

            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                    [0.0, 0.5], [Float(0.5 + sin(Double(meshT)) * 0.15), Float(0.5 + cos(Double(meshT)) * 0.15)], [1.0, 0.5],
                    [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                ],
                colors: [
                    Color(hex: "#050807"), Color(hex: "#0A1210"), Color(hex: "#050807"),
                    Color(hex: "#0A1210"), Color(hex: "#1B5E3B").opacity(Double(ambientPulse)), Color(hex: "#0A1210"),
                    Color(hex: "#050807"), Color(hex: "#0F1F18"), Color(hex: "#050807")
                ]
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    KinexaTheme.accent.opacity(glowIntensity * 0.35),
                    KinexaTheme.brandGreen.opacity(glowIntensity * 0.15),
                    Color.clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 300
            )
            .ignoresSafeArea()
        }
    }

    private var orbField: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let origins: [(x: Double, y: Double, size: Double)] = [
                (0.12, 0.18, 6), (0.88, 0.12, 4), (0.25, 0.75, 5),
                (0.78, 0.82, 7), (0.55, 0.25, 3), (0.08, 0.55, 5)
            ]

            ForEach(0..<6, id: \.self) { i in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                (i % 2 == 0 ? KinexaTheme.accent : KinexaTheme.accent2).opacity(0.6),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: origins[i].size * 3
                        )
                    )
                    .frame(width: origins[i].size * 2, height: origins[i].size * 2)
                    .blur(radius: origins[i].size)
                    .position(
                        x: origins[i].x * w + orbOffsets[i].width,
                        y: origins[i].y * h + orbOffsets[i].height
                    )
                    .opacity(orbOpacities[i])
            }
        }
    }

    private var verticalLightBeam: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.clear,
                        KinexaTheme.accent.opacity(0.08),
                        KinexaTheme.accent.opacity(0.15),
                        KinexaTheme.accent.opacity(0.08),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 2)
            .blur(radius: 8)
            .opacity(verticalBeamOpacity)
            .offset(y: verticalBeamOffset)
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
                                    KinexaTheme.accent.opacity(0.4 - Double(i) * 0.1),
                                    KinexaTheme.accent2.opacity(0.2),
                                    Color.clear,
                                    KinexaTheme.brandGreen.opacity(0.3 - Double(i) * 0.08),
                                    KinexaTheme.accent.opacity(0.4 - Double(i) * 0.1)
                                ],
                                center: .center
                            ),
                            lineWidth: 1.5 - Double(i) * 0.3
                        )
                        .frame(width: 140 + Double(i) * 40, height: 140 + Double(i) * 40)
                        .scaleEffect(ringScales[i])
                        .opacity(ringOpacities[i])
                        .rotationEffect(.degrees(ringRotations[i]))
                }

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                KinexaTheme.accent.opacity(shockwaveOpacity * 0.5),
                                KinexaTheme.accent.opacity(shockwaveOpacity * 0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 180
                        )
                    )
                    .frame(width: 360, height: 360)
                    .scaleEffect(shockwaveScale)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                KinexaTheme.accent.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 55
                        )
                    )
                    .frame(width: 110, height: 110)
                    .opacity(iconOpacity)

                Image(systemName: "figure.run")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [KinexaTheme.accent, KinexaTheme.accent2],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: KinexaTheme.accent.opacity(iconGlowPulse), radius: 40, y: 0)
                    .shadow(color: KinexaTheme.brandGreen.opacity(iconGlowPulse * 0.6), radius: 70, y: 10)
                    .shadow(color: KinexaTheme.accent.opacity(iconGlowPulse * 0.3), radius: 100, y: 0)
                    .scaleEffect(iconScale * iconPulse)
                    .opacity(iconOpacity)
                    .blur(radius: iconBlur)
                    .offset(y: iconYOffset)
                    .rotation3DEffect(.degrees(iconRotation3D), axis: (x: 0, y: 1, z: 0))
            }

            Spacer().frame(height: 36)

            VStack(spacing: 14) {
                HStack(spacing: 2.5) {
                    ForEach(Array(titleText.enumerated()), id: \.offset) { index, char in
                        Text(String(char))
                            .font(.system(size: 30, weight: .black, design: .default))
                            .tracking(1)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.75)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .opacity(titleLetterOpacities[index])
                            .offset(y: titleLetterOffsets[index])
                    }
                }
                .overlay {
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.6), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 80)
                    .offset(x: shimmerX)
                    .mask {
                        HStack(spacing: 2.5) {
                            ForEach(Array(titleText.enumerated()), id: \.offset) { _, char in
                                Text(String(char))
                                    .font(.system(size: 30, weight: .black, design: .default))
                                    .tracking(1)
                            }
                        }
                    }
                }

                HStack(spacing: 0) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.clear, KinexaTheme.accent.opacity(0.5)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: lineWidth, height: 1)
                    Rectangle()
                        .fill(KinexaTheme.accent)
                        .frame(width: 4, height: 4)
                        .clipShape(Circle())
                        .opacity(lineOpacity)
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [KinexaTheme.accent.opacity(0.5), Color.clear],
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
                            colors: [KinexaTheme.accent2, KinexaTheme.secondaryText],
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
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            meshT = 6.28
        }

        for i in 0..<6 {
            let delay = 0.2 + Double(i) * 0.12
            withAnimation(.easeOut(duration: 1.5).delay(delay)) {
                orbOpacities[i] = 1.0
            }
            withAnimation(.easeInOut(duration: Double.random(in: 3...5)).repeatForever(autoreverses: true).delay(delay)) {
                orbOffsets[i] = CGSize(
                    width: Double.random(in: -30...30),
                    height: Double.random(in: -30...30)
                )
            }
        }

        withAnimation(.easeInOut(duration: 1.2).delay(0.3)) {
            verticalBeamOpacity = 1.0
            verticalBeamOffset = 0
        }

        withAnimation(.spring(response: 0.9, dampingFraction: 0.55).delay(0.6)) {
            iconScale = 1.15
            iconOpacity = 1.0
            iconBlur = 0
            iconYOffset = 0
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(1.5)) {
            iconScale = 1.0
        }

        withAnimation(.spring(response: 0.4, dampingFraction: 0.5).delay(1.9)) {
            iconScale = 1.12
        }

        withAnimation(.spring(response: 0.4, dampingFraction: 0.65).delay(2.3)) {
            iconScale = 1.0
        }

        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true).delay(2.5)) {
            iconPulse = 1.06
            iconGlowPulse = 1.0
        }

        withAnimation(.easeInOut(duration: 0.4).delay(1.5)) {
            iconRotation3D = 8
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.9)) {
            iconRotation3D = 0
        }

        withAnimation(.easeOut(duration: 0.8).delay(0.6)) {
            glowIntensity = 1.0
        }

        withAnimation(.spring(response: 0.8, dampingFraction: 0.5).delay(1.0)) {
            shockwaveScale = 1.0
            shockwaveOpacity = 0.8
        }
        withAnimation(.easeOut(duration: 1.0).delay(1.8)) {
            shockwaveOpacity = 0
        }

        for i in 0..<3 {
            let delay = 1.0 + Double(i) * 0.2
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(delay)) {
                ringScales[i] = 1.0
                ringOpacities[i] = 1.0
            }
            withAnimation(.linear(duration: Double(12 + i * 8)).repeatForever(autoreverses: false).delay(delay)) {
                ringRotations[i] += (i % 2 == 0 ? 360 : -360)
            }
        }

        for i in 0..<titleText.count {
            let delay = 2.6 + Double(i) * 0.05
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(delay)) {
                titleLetterOpacities[i] = 1.0
                titleLetterOffsets[i] = 0
            }
        }

        withAnimation(.easeOut(duration: 0.7).delay(3.5)) {
            lineWidth = 60
            lineOpacity = 1.0
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(3.8)) {
            subtitleOpacity = 1.0
            subtitleBlur = 0
        }

        withAnimation(.easeInOut(duration: 1.2).delay(4.0)) {
            shimmerX = 300
        }

        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(1.5)) {
            ambientPulse = 1.0
        }

        withAnimation(.easeInOut(duration: 1.5).delay(2.0)) {
            verticalBeamOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
            withAnimation(.easeIn(duration: 0.3)) {
                iconPulse = 1.15
                iconGlowPulse = 1.3
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.7)) {
                    exitScale = 1.12
                    exitOpacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    onFinished()
                }
            }
        }
    }
}
