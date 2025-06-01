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
  
  var viewModel: GameFieldSceneViewModel = .init()
  private var tableauStacks: [SKShapeNode] = []
  private var isTableauDropZoneVisible = true
  
  // init(viewModel: GameFieldSceneViewModel, size: CGSize) {
  //   self.viewModel = viewModel
  //   super.init(size: size)
  // }
  
  override init(size: CGSize) {
    super.init(size: size)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func didMove(to view: SKView) {
    anchorPoint = CGPoint(x: 0.5, y: 0.5)
    setup()
  }
  
  func setup() {
    setupBackground()
    setFoundationArea()
    setTableauDropZone()
    setStockArea()
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
      let fStacksAreaNode = SKShapeNode(
        rect: CGRect(x: 0, y: 0, width: 50, height: 50 * 1.5),
        cornerRadius: 7
      )
      fStacksAreaNode.position = CGPoint(x: -40 + 55*i, y: 280)
      fStacksAreaNode.zPosition = 0
      

      fStacksAreaNode.strokeColor = .cyan
      fStacksAreaNode.lineWidth = 1
      fStacksAreaNode.glowWidth = 1
      fStacksAreaNode.fillColor = UIColor(hex: "#f17d85")!.withAlphaComponent(0.2)
      // fStacksAreaNode.strokeColor = .orange
      DispatchQueue.main.async {
        self.viewModel.foundationStacks[i].dropZone = fStacksAreaNode.frame
      }
      addChild(fStacksAreaNode)
      
    }
  }
  
  func setTableauDropZone() {
    // MARK: - Tableau Stack Area
    
    // position을 height의 절반만큼 내리기
    let height: CGFloat = 600
    
    for i in viewModel.tableauStacks.indices {
      let node = SKShapeNode(rectOf: CGSize(width: 50, height: height))
      node.fillColor = .systemPink.withAlphaComponent(0.3)
      node.strokeColor = .white
      node.position = CGPoint(
        x: CGFloat(-170 + i * 55),
        y: -height / CGFloat(2) + 250
      )
      node.zPosition = 0
      DispatchQueue.main.async {
        self.viewModel.tableauStacks[i].dropZone = node.frame
      }
      
      tableauStacks.append(node)
      addChild(node)
    }
  }
  
  func toggleTableuDropZone() {
    isTableauDropZoneVisible.toggle()
    
    tableauStacks.forEach { node in
      if isTableauDropZoneVisible {
        node.fillColor = .systemPink.withAlphaComponent(0.3)
        node.strokeColor = .white
      } else {
        node.fillColor = .clear
        node.strokeColor = .clear
      }
    }
  }
  
  func setStockArea() {
    let stockAreaNode = StockAreaNode()
    stockAreaNode.position = CGPoint(x: -170, y: 320)
    stockAreaNode.zPosition = 0
    stockAreaNode.delegate = viewModel
    addChild(stockAreaNode)
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
          y: 200 - Int(UI_VERTICAL_CARD_SPACING) * j
        )
        cardNode.zPosition = CGFloat((i + 1) * 100 + j)
        
        cardNode.delegate = viewModel
        cardNode.DEBUG_drawZPos()
        addChild(cardNode)
      }
    }
  }
  
  func setStockCardNodes() {
    // MARK: - Stock Pile setup
    
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
  
  func removeAllNodes() {
    children.forEach {
      $0.removeFromParent()
    }
  }
  
  func removeWasteCardNodes() {
    viewModel.wasteStacks.forEach { card in
      childNode(withName: card.dataDescription)?.removeFromParent()
    }
  }
  
  func cardNodes(cardArray: [Card]) -> [CardNode] {
    cardArray.compactMap { card in
      childNode(withName: card.dataDescription) as? CardNode
    }
  }
  
  func pasteCardsToBottom(_ cardNode: CardNode, pasteCards: [Card]) {
    let pastCardNodes = cardNodes(cardArray: pasteCards)
    pastCardNodes.forEach { childNode in
      childNode.removeFromParent()
      cardNode.addChild(childNode)
      childNode.position = cardNode.convert(childNode.position, from: self)
    }
  }
  
  func detachCardsFromChunks(_ cardNode: CardNode, prevTopCardNode: CardNode? = nil) {
    if cardNode.isGroupLeader {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + 0.01) {
        _ = cardNode.children.reduce(1) { childIndex, child in
          guard child is CardNode else {
            return childIndex
          }
          
          var newPostion = child.convert(child.position, to: self)
          
          if let prevTopCardNode {
            newPostion.y = prevTopCardNode.position.y - CGFloat((childIndex + 1) * UI_VERTICAL_CARD_SPACING)
            child.zPosition = prevTopCardNode.zPosition + 1 + childIndex
          } else {
            // 이거 안하면 y 위치 어긋남
            newPostion.y += CGFloat(childIndex * UI_VERTICAL_CARD_SPACING)
            child.zPosition = cardNode.zPosition + childIndex
          }
          
          child.position = newPostion
          child.removeFromParent()
          self.addChild(child)
          
          return childIndex + 1
        }
      }
      
      cardNode.isGroupLeader = false
    }
  }
}

struct GameFieldSceneView: View {
  // @StateObject var viewModel = GameFieldSceneViewModel()
  @State private var faceUpCounts = ""
  @State private var scene = GameFieldScene(
    size: CGSize(
      width: UIScreen.main.bounds.width,
      height: UIScreen.main.bounds.height
    )
  )

  var body: some View {
    ZStack(alignment: .bottom) {
      SpriteView(scene: scene)
      .onAppear(perform: setupCards)
      .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
      .ignoresSafeArea()
      
      VStack {
        HStack {
          Button("Reset") {
            scene.viewModel.setNewCards()
            scene.removeAllNodes()
            scene.setup()
          }
          Button("ShowTDropZone") {
            scene.toggleTableuDropZone()
          }
        }
        .foregroundStyle(.cyan)
        Text(faceUpCounts)
          .foregroundStyle(.white)
      }
      .font(.custom("SevenSegmentRegular", size: 15))
      .padding(.horizontal, 10)
      .background(.black)
      .onReceive(scene.viewModel.$tableauStacks) { output in
        faceUpCounts = scene.viewModel.tableauStacks.map {
          "\($0.faceUpCount)"
        }.joined(separator: "  ")
      }
      .background(.white)
      .offset(y: -50)
    }
  }
  
  private func setupCards() {
    scene.viewModel.setNewCards()
    // viewModel.setTableauStacks()
  }
}

#Preview {
  GameFieldSceneView()
}
