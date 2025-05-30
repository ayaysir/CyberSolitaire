//
//  GameFieldSceneView.swift
//  CyberSolitaire
//
//  Created by 윤범태 on 5/25/25.
//

import SwiftUI
import SpriteKit

class GameFieldScene: SKScene {
  // 💡: Scene을 SwiftUI View 안에 두는것보다 외부로 빼는것이 속도면에서 훨씬 빠름
  
  var viewModel: GameFieldSceneViewModel
  
  init(viewModel: GameFieldSceneViewModel, size: CGSize) {
    self.viewModel = viewModel
    super.init(size: size)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func didMove(to view: SKView) {
    anchorPoint = CGPoint(x: 0.5, y: 0.5)
    setupBackground()
    
    setFoundationArea()
    setTableauDropZone()
    setTableauCardNodes()
    setStockCardNodes()
  }
  
  func setupBackground() {
    let backgroundTexture = SKTexture(image: .cyberpunk1)
    let backgroundNode = SKSpriteNode(texture: backgroundTexture)
    backgroundNode.position = .zero
    backgroundNode.size = size
    backgroundNode.zPosition = -1
    
    addChild(backgroundNode)
  }
  
  func setFoundationArea() {
    // 4 right-upper fStacks
    for i in 0..<4 {
      let fStacksAreaNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 50, height: 50 * 1.5))
      fStacksAreaNode.position = CGPoint(x: -40 + 55*i, y: 280)
      fStacksAreaNode.fillColor = .white.withAlphaComponent(0.5)
      DispatchQueue.main.async {
        self.viewModel.foundationStacks[i].dropZone = fStacksAreaNode.frame
      }
      addChild(fStacksAreaNode)
    }
  }
  
  func setTableauDropZone() {
    // MARK: - Tableau Stack Area
    
    for i in viewModel.tableauStacks.indices {
      let node = SKShapeNode(rectOf: CGSize(width: 50, height: 500))
      node.fillColor = .systemMint.withAlphaComponent(0.3)
      node.position = CGPoint(
        x: -170 + i * 55,
        y: 0
      )
      DispatchQueue.main.async {
        self.viewModel.tableauStacks[i].dropZone = node.frame
      }
      
      addChild(node)
    }
  }
  
  func setTableauCardNodes() {
    // MARK: - CardNodes Tableau Setup
    
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
        
        cardNode.delegate = viewModel
        addChild(cardNode)
      }
    }
  }
  
  func setStockCardNodes() {
    // MARK: - Stock Pile setup
    
    let stockAreaNode = StockAreaNode()
    stockAreaNode.position = CGPoint(x: -170, y: 320)
    stockAreaNode.delegate = viewModel
    addChild(stockAreaNode)
    
    for i in viewModel.stockStacks.indices {
      let card = viewModel.stockStacks[i]
      let cardNode = CardNode(
        card: card,
        displayMode: .back,
        dropZone: nil
      )
      cardNode.name = card.dataDescription
      cardNode.position = CGPoint(
        x: -170 + 0.5 * CGFloat(i),
        y: 320 - 0.2 * CGFloat(i)
      )
      
      cardNode.delegate = viewModel
      addChild(cardNode)
    }
  }
  
  func removeStockCardNodes() {
    viewModel.stockStacks.forEach { card in
      childNode(withName: card.dataDescription)?.removeFromParent()
    }
  }
  
  func cardNodes(cardArray: [Card]) -> [CardNode] {
    cardArray.compactMap { card in
      childNode(withName: card.dataDescription) as? CardNode
    }
  }
}

struct GameFieldSceneView: View {
  @StateObject var viewModel = GameFieldSceneViewModel()
  
  var body: some View {
    VStack {
      SpriteView(
        scene: GameFieldScene(
          viewModel: viewModel,
          size: CGSize(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height - 50
          )
        )
      )
      .onAppear(perform: setupCards)
      .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 50)
      .ignoresSafeArea()
      Spacer()
      HStack {
        ForEach(viewModel.tableauStacks.indices, id: \.self) { i in
          Text("\(viewModel.tableauStacks[i].faceUpCount)")
        }
      }
    }
  }
  
  private func setupCards() {
    viewModel.setNewCards()
    viewModel.setTableauStacks()
  }
}

#Preview {
  GameFieldSceneView()
}
