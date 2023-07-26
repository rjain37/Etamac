//
//  ContentView.swift
//  Trader's Central
//
//  Created by rohan jain on 6/18/23.
//

import SwiftUI

enum GameState {
    case home
    case playingArithmetic
}

struct QuestionGenerator {
    static func generateProblem() -> String {

        let operation = ["+", "-", "*", "/"].randomElement() ?? "+"
        
        var problem = ""
        
        switch operation {
        case "+":
            let number1 = Int.random(in: 2...100)
            let number2 = Int.random(in: 2...100)
            problem = "\(number1) + \(number2) ="
        case "-":
            let number1 = Int.random(in: 2...100)
            let number2 = Int.random(in: 2...100)
            let sum = number1 + number2
            problem = "\(sum) - \(number2) ="
        case "*":
            let number1 = Int.random(in: 2...12)
            let number2 = Int.random(in: 2...100)
            problem = "\(number1) * \(number2) ="
        case "/":
            let number1 = Int.random(in: 2...12)
            let number2 = Int.random(in: 2...100)
            let product = number1 * number2
            problem = "\(product) / \(number1) ="
        default:
            break
        }
        
        return problem
    }
}

struct ContentView: View {
    enum FocusedField{
        case start
    }
    @State private var score = 0
    @State private var timeRemaining = 120
    @State private var currentProblem = ""
    @State private var userAnswer = ""
    @State private var showAlert = false
    @State private var gameState: GameState = .home
    @FocusState private var isTextFieldFocused: FocusedField?
    
    @AppStorage("bestScore") private var bestScore = 0
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            if gameState == .home {
                homeView
            } else if gameState == .playingArithmetic {
                gameView
            }
        }
    }
    
    var homeView: some View {
        VStack {
            Text("Arithmetic Game")
                .font(.title)
            
            Text("You will have 120 seconds to answer as many arithmetic questions as you can. Good luck!")
                .font(.body)
            
            Button(action: startGame) {
                Text("Start Game")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }

    var gameView: some View {
            VStack {
                HStack {
                    Button(action: restartGame) {
                        Image(systemName: "arrow.counterclockwise.circle")
                            .font(.title)
                    }
                    .padding()
                    
                    Text("Score: \(score)")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("Time: \(timeRemaining)")
                        .font(.headline)
                        .onReceive(timer) { _ in
                            if timeRemaining > 0 {
                                timeRemaining -= 1
                            } else {
                                endGame()
                            }
                        }
                    
                    Spacer()
                    
                    Text("Best Score: \(bestScore)")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.trailing, 20)
                }
                
                Text("\(currentProblem)")
                    .font(.largeTitle)
                
                TextField("Your Answer", text: $userAnswer)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: userAnswer){ newValue in
                        checkAnswer()
                    }
                    .padding()
                    .keyboardType(.numberPad)
                    .disabled(showAlert)// Disable the text field when the game is over
                    .focused($isTextFieldFocused, equals: .start)
            }
            .onAppear{
                isTextFieldFocused = .start
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Game Over"),
                    message: Text("Your final score is \(score)"),
                    dismissButton: .default(Text("Play Again"), action: restartGame)
                )
            }
            .onAppear(perform: restartGame) // Start the game when the view appears
            .onChange(of: userAnswer){ newValue in
                updateBestScore()
            }
        }
    
    func startGame() {
        score = 0
        timeRemaining = 120
        generateNewProblem()
        gameState = .playingArithmetic
    }
    
    func generateNewProblem() {
        currentProblem = QuestionGenerator.generateProblem()
    }
    
    func checkAnswer() {
        guard let userNumber = Int(userAnswer) else { return }
        
        let problemComponents = currentProblem.components(separatedBy: " ")
        
        guard problemComponents.count == 4,
              let number1 = Int(problemComponents[0]),
              let number2 = Int(problemComponents[2]),
              let operation = problemComponents[1].first
        else {
            return
        }
        
        var correctAnswer: Int
        
        switch operation {
        case "+":
            correctAnswer = number1 + number2
        case "-":
            correctAnswer = number1 - number2
        case "*":
            correctAnswer = number1 * number2
        case "/":
            correctAnswer = number1 / number2
        default:
            return
        }
        
        if userNumber == correctAnswer {
            score += 1
            userAnswer = ""
            generateNewProblem()
        }
    }
    
    func endGame() {
        showAlert = true
        updateBestScore()
    }
    
    func restartGame() {
        score = 0
        timeRemaining = 120
        userAnswer = ""
        generateNewProblem()
        startGame()
        gameState = .playingArithmetic
    }
    
    func updateBestScore(){
        if score > bestScore {
            bestScore = score
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
