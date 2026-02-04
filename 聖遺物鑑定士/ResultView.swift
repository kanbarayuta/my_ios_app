//
//  ResultView.swift
//  ArtifactAppraiser
//
import SwiftUI

struct ResultView: View {
    @Binding var screen:Screen
    let elapsed: TimeInterval
    let maxScore: Double
    let maxScoreArtifact: String
    private let questionCount = 20

    var body: some View {
        ZStack {
            ResultBackground()
            ScrollView {
                VStack {
                    VStack {
                        VStack(spacing: 20) {
                            Text("〜Result〜")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                            Spacer()
                                .frame(height: 16)
                            HStack {
                                Text("Time : ")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                Spacer()
                                Text("\(String(format: "%.2f", elapsed))")
                                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                            }
                            HStack {
                                Text("Average : ")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                Spacer()
                                Text("\(String(format: "%.2f", elapsed / Double(questionCount)))")
                                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                            }
                            HStack {
                                Text("Max Score Aritfact :")
                                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                                Spacer()
                            }
                            Text(String(format: "%.1f", maxScore))
                                .font(.system(size: 50, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(.myYellow)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 36)
                        .background(.myYellow.opacity(0.2))
                        .overlay {
                            Rectangle()
                                .strokeBorder(.myYellow, lineWidth: 2)
                        }
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 20)
                    if !maxScoreArtifact.isEmpty {
                        Image(maxScoreArtifact)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160, height: 160)
                            .shadow(color: .myYellow, radius: 20)
                    }
                    Button {
                        screen = .start
                    } label: {
                        Text("TITLE")
                            .font(.system(size: 36).bold())
                            .foregroundStyle(.myYellow)
                            .shadow(color: .myYellow, radius: 5)
                            .padding()
                    }
                    .padding(.top, 70)
                    .padding(.bottom,10)
                    
                }
                .padding()
            }
        }
    }
}
struct ResultBackground: View {
    var body: some View {
        GeometryReader { geo in
            if geo.size.width >= 600 {
                // iPad / 大画面用
                Image("mainBackgroundiPad")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
            } else {
                // iPhone 用
                Image("mainBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .offset(x: -15)
            }
        }
        .ignoresSafeArea()
    }
}
