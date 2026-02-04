//
//  ContentView.swift
//  DiagnosticApp

import SwiftUI
// 画面の種類
enum Screen{
    case start
    case question
    case result
}

// 診断の種類
enum DiagnosisType {
    case personality
    case compatibility
    case love
}

// 答えの選択パターン
enum AnswerType {
    case binary      // YES/ON
    case scale(Int)  // 1 ~ N
}

// 問題文を保管する型
struct Question {
    let id = UUID()
    let q_sentence: String
    let answerType: AnswerType
    let axis: Axis?
    var answer: Int? = nil
}
enum Axis {
    case meritDemerit
    case logic
    case responsibility
    case approval
}

// 全てのViewを管理するためのView
struct ContentView: View {
    @State private var screen: Screen = .start
    @State private var selectedType: DiagnosisType? = nil
    @State private var questions: [Question] = []
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .fill(
                    LinearGradient(
                        colors: [.mybgGreen,.white],
                        startPoint: .top,
                        endPoint: .bottom
                        )
                    )
                .ignoresSafeArea()
            switch screen {
            case .start:
                DiagosisSelectView(
                    screen: $screen,
                    selectedType: $selectedType,
                    questions: $questions
                )
                
            case .question:
                if let type = selectedType {
                    QuestionView(
                        screen: $screen,
                        selectedType: type,
                        questions: $questions
                    )
                }
                
            case .result:
                if let type = selectedType {
                    ResultView(
                        screen: $screen,
                        selectedType: type,
                        questions: questions
                    )
                }
            }
        }
    }
}

// 問題文を管理するための箱
struct DiagnosisData {
    static let personality: [Question] = [
        Question(
            q_sentence: "自分は長男（長女）または一人っ子ではない",
            answerType: .binary,
            axis: .meritDemerit
            
        ),
        Question(
            q_sentence: "自分がやった宿題を友達に見せることに抵抗がない",
            answerType: .scale(5),
            axis: .meritDemerit
            
        ),
        Question(
            q_sentence: "異性の友情は成立すると思う",
            answerType: .binary,
            axis: .approval
        ),
        Question(
            q_sentence: "友達と遊ぶ際、待ち合わせには時間に余裕を持って家を出るタイプだ",
            answerType: .binary,
            axis: .meritDemerit
        ),
        Question(
            q_sentence: "他人を羨ましいと感じた後、自分の行動や判断に意識が向くことは少ない",
            answerType: .binary,
            axis: .responsibility
        ),
        Question(
            q_sentence: " 仲の良い友達なら自分が興味のない遊びでも付き合う",
            answerType: .scale(5),
            axis: .meritDemerit
        ),
        Question(
            q_sentence: "テストの過去問を手に入れた場合、友達に共有しようと思う",
            answerType: .binary,
            axis: .meritDemerit
        ),
        Question(
            q_sentence: "同性の友達と同様に異性の友達とも肩が組める",
            answerType: .binary,
            axis: .approval
        ),
        Question(
            q_sentence: "友達との予定が白紙になっても、別の友達と遊べば特に問題がないと感じる",
            answerType: .binary,
            axis: .meritDemerit
        ),
        Question(
            q_sentence: "転売ヤーは悪だと思う",
            answerType: .binary,
            axis: .logic
        ),
        Question(
            q_sentence: "自分で選択した行動の結果でも、後悔することがある",
            answerType: .binary,
            axis: .responsibility
        ),
        Question(
            q_sentence: "他人に対して、自分と同じレベルの配慮や判断を期待してしまうことがある",
            answerType: .scale(5),
            axis: .meritDemerit
        ),
        Question(
            q_sentence: "場の空気を優先して意見を控えた後、その判断について後からモヤッとした感情が残ることがある",
            answerType: .binary,
            axis: .logic
        )
    ]
    
    static let compatibility: [Question] = [
        Question(
            q_sentence: "意見が違っても話し合えると思う",
            answerType: .binary,
            axis: nil
        ),
        Question(
            q_sentence: "価値観の違いは楽しめる方だ",
            answerType: .scale(5),
            axis: nil
        )
    ]
    
    static let love: [Question] = [
        Question(
            q_sentence: "恋愛では直感を信じる",
            answerType: .binary,
            axis: nil
        ),
        Question(
            q_sentence: "相手に合わせることが多い",
            answerType: .scale(5),
            axis: nil
        )
    ]
    
}

struct DiagosisSelectView: View {
    @Binding var screen: Screen
    @Binding var selectedType: DiagnosisType?
    @Binding var questions:[Question]
    
    var body: some View {
        VStack {
            Spacer()
            Text("診断テスト")
                .modifier(TitleStyle())
            Spacer()
            VStack(spacing: 36) {
                Button("性格診断") {
                    screen = .question
                    questions = DiagnosisData.personality
                    selectedType = .personality
                }
                .modifier(DiagnosisButtonStyle())
                
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 3)
                    .padding(.horizontal, 40)
                    .opacity(0.8)
                
                Button("思想診断") {
                    screen = .question
                    questions = DiagnosisData.compatibility
                    selectedType = .compatibility
                }
                .modifier(ComingSoonButtonStyle())
                .disabled(true)
                
                Rectangle()
                    .fill(Color.gray)
                    .frame(height: 3)
                    .padding(.horizontal, 40)
                    .opacity(0.3)
                
                Button("coming soon") {
                    screen = .question
                    questions = DiagnosisData.love
                    selectedType = .love
                }
                .modifier(ComingSoonButtonStyle())
                .disabled(true)
            }
            Spacer()
        }
        .padding(48)
    }
}

struct QuestionView: View {
    @Binding var screen: Screen
    let selectedType: DiagnosisType
    @Binding var questions: [Question]
    @State private var currentIndex: Int = 0
        
    var body: some View {
        VStack {
            Text("\(currentIndex + 1) / \(questions.count)")
                .modifier(TitleStyle())
            Text(questions[currentIndex].q_sentence)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .padding(20)
                .frame(maxWidth: .infinity)
                .frame(height: 240)
                .background {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.white)

                        Text("Q")
                            .font(.system(size: 160, weight: .bold, design: .rounded))
                            .foregroundStyle(.mybgGreen.opacity(0.3))
                    }
                }
            // 小さい白いバー
            RoundedRectangle(cornerRadius: 100)
                .fill(.white)
                .frame(width: 100, height: 50)
                .padding(.top, 8)
            // 小さい白いバー
            RoundedRectangle(cornerRadius: 100)
                .fill(.white)
                .frame(width: 40, height: 30)
                .padding(.top, 8)
            
            Spacer()
            HStack {
                AnswerInputView(answerType: questions[currentIndex].answerType) { value in
                    questions[currentIndex].answer = value
                    goNext()
                }
            }
            .frame(height: 100)
            Spacer()
            Button("結果を表示") {
                screen = .result
            }
            .font(.title)
            .padding()
            .foregroundStyle(currentIndex == questions.count - 1 ? .mybgGreen : .white)
            .background(currentIndex == questions.count - 1 ? .white : .gray)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.top,20)
            .disabled(currentIndex != questions.count - 1)
            
            Spacer()
        }
        .padding(36)
    }

    func goNext(){
        if currentIndex < questions.count - 1 {
            currentIndex += 1
        }
    }
}

struct AnswerInputView: View {
    let answerType: AnswerType
    let onSelect: (Int) -> Void

    var body: some View {
        HStack {
            switch answerType {
            case .binary:
                Button("YES") { onSelect(1) }
                    .foregroundStyle(.yes)
                    .modifier(Button_small())
                Button("NO")  { onSelect(0) }
                    .foregroundStyle(.no)
                    .modifier(Button_small())

            case .scale(let max):
                Text("思わない")
                    .frame(width: 40)
                ForEach(1...max, id: \.self) { value in
                    Button("\(value)") {
                        onSelect(value)
                    }
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.black)
                    .frame(width: 40)
                    .background(.myGray)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                Text("思う")
                    .frame(width: 40)
            }
        }
    }
}

struct DiagosisResult {
    let title: String
    let description: String
}
struct DiagosisEvaluator {
    static func evaluate (
        type: DiagnosisType,
        questions: [Question]
    ) -> DiagosisResult {
        switch type {
        case .personality:
            return evaluatePersonality(questions)
        case .compatibility:
            return evaluateCompatibility(questions)
        case .love:
            return evaluateLove(questions)
        }
    }
    static func evaluatePersonality(_ questions: [Question]) -> DiagosisResult {
        let binaryScores = [-2.0, 2.0]
        let scale5Scores = [0, -3, -2, 0.5, 2, 3]

        var scores: [Axis: Double] = [
            .meritDemerit: 0,
            .logic: 0,
            .responsibility: 0,
            .approval: 0
        ]
        for q in questions {
            guard
                let axis = q.axis,
                let answer = q.answer
            else { continue }
            let value: Double
            switch q.answerType {
            case .binary:
                value = binaryScores[answer]
            case .scale(_):
                value = scale5Scores[answer]
            }
            scores[axis,default:0] += value
        }
        // scoreを計算する
        return makePersonalityResult(from: scores)
    }
    static func makePersonalityResult(
    from scores: [Axis: Double]
    ) -> DiagosisResult {
        var meritScore = scores[.meritDemerit,default: 0]
        var logicScore = scores[.logic,default: 0]
        if logicScore == 0 {
            logicScore = -1
        } else if logicScore < 0 {
            logicScore = -2
        }
        meritScore += logicScore
        if meritScore > 0 {
            return DiagosisResult(
                title: "デメリット回避型",
                description: "あなたはデメリット回避型です。明確なメリットがなくても、「少なくともマイナスではない」と判断できれば行動できます。状況を論理的に整理できたときには、一時的にメリット追求型のような行動を取ることもあります。ただし、行動基準そのものが異なるため、常にメリットを基準に動くタイプとは価値観のズレを感じやすい傾向があります。"
            )
        } else {
            return DiagosisResult(
                title: "メリット追求型",
                description: "あなたはメリット追求型です。行動の基準は「自分にとってプラスになるかどうか」。その分、明確なメリットが見えない状況では動きづらさを感じやすい傾向があります。行動基準が異なるため、デメリット回避型とは価値観のズレを感じやすいでしょう。"
            )
        }
    }


    static func evaluateCompatibility(_ questions: [Question]) -> DiagosisResult {
        DiagosisResult(
            title: "仮のタイトル",
            description: "仮の説明"
        )
    }
    static func evaluateLove(_ questions: [Question]) -> DiagosisResult {
        DiagosisResult(
            title: "仮のタイトル",
            description: "仮の説明"
        )
    }

}

struct ResultView: View {
    @Binding var screen: Screen
    let selectedType: DiagnosisType
    let questions: [Question]
    var result: DiagosisResult{
        DiagosisEvaluator.evaluate(
            type: selectedType,
            questions: questions
        )
    }
    var body: some View {
        VStack {
            Text("診断結果")
                .modifier(TitleStyle())
            VStack {
                Text(result.title)
                    .font(.title)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(.mybgGreen)
                Text(result.description)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Text("※ 本診断は娯楽目的であり、医学・心理学的診断ではありません")
                    .font(.caption)

            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            Spacer()
            
            Button("一覧に戻る") {
                screen = .start
            }
            .font(.title)
            .padding()
            .foregroundStyle(.white)
            .background(.gray)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.top,20)
            
            Spacer()
        }
        .padding(36)
    }
}

// ViewModifier
struct DiagnosisButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 40, weight: .bold))
            .foregroundStyle(.white)
            .padding(10)
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white, lineWidth: 4)
            )
    }
}
struct ComingSoonButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 40, weight: .bold))
            .foregroundStyle(.gray)
            .padding(10)
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 4)
            )
            .opacity(0.5)
    }
}

struct TitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 48, weight: .bold))
            .foregroundStyle(.white)
            .padding(.vertical, 40)
    }
}

struct Button_small: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 50, weight: .bold, design: .rounded))
            .padding(20)
            .frame(width: 150)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .padding(.top, 30)
    }
}
#Preview {
    ContentView()
}
