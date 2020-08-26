//
//  GameView.swift
//  SimpeSnakeSwiftUI
//
//  Created by Vadim Denisov on 26.08.2020.
//  Copyright © 2020 Vadim Denisov. All rights reserved.
//

import SwiftUI

struct GameView: View {
    
    @State var startPosition: CGPoint = .zero
    @State var isStarted: Bool = true
    @State var gameOver: Bool = false
    @State var direction: Direction = .down
    @State var snakePositions: [CGPoint] = [.zero]
    @State var foodPosition: CGPoint = .zero
    
    let snakeSize: CGFloat = 10
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    let minX = UIScreen.main.bounds.minX
    let maxX = UIScreen.main.bounds.maxX
    let minY = UIScreen.main.bounds.minY
    let maxY = UIScreen.main.bounds.maxY
    
    var body: some View {
        ZStack {
            Color.pink.opacity(0.3)
            ZStack {
                ForEach(0..<snakePositions.count, id: \.self) { index in
                    Rectangle()
                        .frame(width: self.snakeSize, height: self.snakeSize)
                        .position(self.snakePositions[index])
                }
                Rectangle()
                    .fill(Color.red)
                .frame(width: snakeSize, height: snakeSize)
                .position(foodPosition)
            }.onAppear() {
                self.foodPosition = self.newRandomPosition()
                self.snakePositions[0] = self.newRandomPosition()
            }
            
            if gameOver {
                VStack {
                    Text("Game Over")
                    Text("Score: \(snakePositions.count - 1)")
                }
            }
        }
        .gesture(DragGesture()
            .onChanged { gesture in
                if self.isStarted {
                    self.startPosition = gesture.location
                    self.isStarted.toggle()
                }
            }
            .onEnded { gesture in
                let xDist = abs(gesture.location.x - self.startPosition.x)
                let yDist = abs(gesture.location.y - self.startPosition.y)
                let isHorizontalSwipe = yDist > xDist
                
                if self.startPosition.y < gesture.location.y && isHorizontalSwipe {
                    self.direction = .down
                } else if self.startPosition.y > gesture.location.y && isHorizontalSwipe {
                    self.direction = .up
                } else if self.startPosition.x > gesture.location.x && !isHorizontalSwipe {
                    self.direction = .right
                } else if self.startPosition.x < gesture.location.x && !isHorizontalSwipe {
                    self.direction = .left
                }
                self.isStarted.toggle()
            }
        )
        .gesture(TapGesture()
            .onEnded { gesture in
                if self.gameOver {
                    self.snakePositions = [self.newRandomPosition()]
                    self.foodPosition = self.newRandomPosition()
                    self.gameOver.toggle()
                }
            }
        )
        .onReceive(timer) { _ in
            if !self.gameOver {
                self.changeDirection()
                if self.snakePositions[0] == self.foodPosition {
                    self.snakePositions.append(self.snakePositions[0])
                    self.foodPosition = self.newRandomPosition()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    func newRandomPosition() -> CGPoint {
        let rows = Int(maxX / snakeSize)
        let cols = Int(maxY / snakeSize)
        
        let randomX = Int.random(in: 1..<rows) * Int(snakeSize)
        let randomY = Int.random(in: 1..<cols) * Int(snakeSize)
        
        return CGPoint(x: randomX, y: randomY)
    }
    
    func changeDirection() {
        let isGameOver = snakePositions[0].x < minX || snakePositions[0].x > maxX || snakePositions[0].y < minY || snakePositions[0].y > maxY
        if isGameOver && !gameOver {
            gameOver.toggle()
        }
        
        var previousPosition = snakePositions[0]
        switch direction {
        case .down:
            snakePositions[0].y += snakeSize
        case .up:
            snakePositions[0].y -= snakeSize
        case .left:
            snakePositions[0].x += snakeSize
        case .right:
            snakePositions[0].x -= snakeSize
        }
        
        for index in 1..<snakePositions.count {
            let current = snakePositions[index]
            snakePositions[index] = previousPosition
            previousPosition = current
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
