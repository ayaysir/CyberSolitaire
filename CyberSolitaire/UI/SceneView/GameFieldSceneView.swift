//
//  GameFieldSceneView.swift
//  CyberSolitaire
//
//  Created by 윤범태 on 5/25/25.
//

import SwiftUI
import SpriteKit

struct GameFieldSceneView: View {
  @StateObject var viewModel = GameFieldSceneViewModel()
  let cardHandler = GameFieldCardInteractionHandler()
  
  var body: some View {
    VStack {
      SpriteView(scene: scene)
        .onAppear(perform: setupCards)
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .ignoresSafeArea()
      Spacer()
    }
  }
  
  private func setupCards() {
    var newCards: [Card] = []
    for suit in [Card.Suit.heart, .diamond, .club, .spade] {
      for rank in 1...13 {
        newCards.append(Card(suit: suit, rank: rank))
      }
    }
    viewModel.cards = newCards
      // .shuffled()
  }
}

extension GameFieldSceneView: HasScene {
  var scene: SKScene {
    let scene = SKScene()
    scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    scene.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    setupBackground(scene: scene)
    
    let deckAreaNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 100, height: 150))
    deckAreaNode.position = CGPoint(x: -160, y: -200)
    deckAreaNode.fillColor = .white.withAlphaComponent(0.5)
    // frame은 부모 뷰 기준 위치와 크기, bounds는 자기 자신 기준 내부 좌표계와 크기입니다.
    scene.addChild(deckAreaNode)
    
    // cardHandler.dropZone = deckAreaNode.frame
    cardHandler.viewModel = viewModel
    
    // 4 right-upper decks
    for i in 0..<4 {
      let deckAreaNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 52, height: 52 * 1.5))
      deckAreaNode.position = CGPoint(x: -80 + 65*i, y: 280)
      deckAreaNode.fillColor = .white.withAlphaComponent(0.5)
      DispatchQueue.main.async {
        cardHandler.viewModel?.decks[i].dropZone = deckAreaNode.frame
      }
      scene.addChild(deckAreaNode)
    }
    
    // MARK: - CardNodes Setup
    for i in viewModel.cards.indices {
      let cardNode = CardNode(
        card: viewModel.cards[i],
        displayMode: .fullFront,
        dropZone: deckAreaNode.frame
      )
      
      let suitIndex = i / 13  // 어떤 suit인지 (0, 1, 2, 3)
      let cardInSuit = i % 13  // suit 내에서 몇 번째 카드인지 (0~12)
      
      cardNode.position = CGPoint(
        x: -170 + 27 * cardInSuit,
        y: 200 - 50 * suitIndex
      )
      
      cardNode.delegate = cardHandler
      scene.addChild(cardNode)
    }
    
    return scene
  }
  
  func setupBackground(scene: SKScene) {
    let backgroundTexture = SKTexture(image: .cyberpunk1)
    let backgroundNode = SKSpriteNode(texture: backgroundTexture)
    backgroundNode.position = .zero
    backgroundNode.size = scene.size
    backgroundNode.zPosition = -1
    
    scene.addChild(backgroundNode)
  }
}

#Preview {
  GameFieldSceneView()
}
