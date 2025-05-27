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
    viewModel.setNewCards()
    viewModel.setTableauStacks()
  }
}

extension GameFieldSceneView: HasScene {
  var scene: SKScene {
    let scene = SKScene()
    scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    scene.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    setupBackground(scene: scene)
    
    // cardHandler.dropZone = deckAreaNode.frame
    cardHandler.viewModel = viewModel
    
    // 4 right-upper fStacks
    for i in 0..<4 {
      let fStacksAreaNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 52, height: 52 * 1.5))
      fStacksAreaNode.position = CGPoint(x: -80 + 65*i, y: 280)
      fStacksAreaNode.fillColor = .white.withAlphaComponent(0.5)
      DispatchQueue.main.async {
        viewModel.foundationStacks[i].dropZone = fStacksAreaNode.frame
      }
      scene.addChild(fStacksAreaNode)
    }
    
    // MARK: - Tableau Stack Area
    
    for i in viewModel.tableauStacks.indices {
      let node = SKShapeNode(rectOf: CGSize(width: 50, height: 500))
      node.fillColor = .systemMint.withAlphaComponent(0.3)
      node.position = CGPoint(
        x: -170 + i * 55,
        y: 0
      )
      DispatchQueue.main.async {
        viewModel.tableauStacks[i].dropZone = node.frame
      }
      scene.addChild(node)
    }
    
    // MARK: - CardNodes Setup
    
    for i in viewModel.tableauStacks.indices {
      for j in viewModel.tableauStacks[i].cards.indices {
        let card = viewModel.tableauStacks[i].cards[j]
        let displayMode: Card.DisplayMode = j == viewModel.tableauStacks[i].cards.count - 1 ? .fullFront : .back
        let cardNode = CardNode(
          card: card,
          displayMode: displayMode,
          dropZone: nil
        )
        
        cardNode.position = CGPoint(
          x: -170 + 55 * i,
          y: 200 - 50 * j
        )
        
        cardNode.delegate = cardHandler
        scene.addChild(cardNode)
      }
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
