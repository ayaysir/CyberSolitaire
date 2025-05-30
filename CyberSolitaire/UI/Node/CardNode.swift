//
//  CardNode.swift
//  CyberSolitaire
//
//  Created by 윤범태 on 4/28/25.
//

import SwiftUI
import SpriteKit
import BGSMM_DevKit

class CardNode: SKSpriteNode {
  var card: Card
  var width: CGFloat = 50
  var displayMode: Card.DisplayMode
  var dropZone: CGRect?
  var originalZPosition: CGFloat?
  
  weak var delegate: CardNodeDelegate?
  
  // Drag 프로퍼티
  /// true인 경우 touchMoved, Ended 이벤트 지속, false인 경우 began으로 종료
  private var isDragging = false
  private var dragOffset = CGPoint.zero
  private var originalDragPosition = CGPoint.zero
  
  init(card: Card, displayMode: Card.DisplayMode, dropZone: CGRect? = nil) {
    self.card = card
    self.displayMode = displayMode
    let size = CGSize(width: width, height: width * 1.5)
    
    super.init(texture: nil, color: .clear, size: size)
    self.isUserInteractionEnabled = true // 필요에 따라 true
    
    if let dropZone {
      self.dropZone = dropZone
    }
    
    setupUI()
    name = card.dataDescription
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupUI() {
    let cardContainer = SKNode()
    
    switch card.suit {
    case .heart, .diamond:
      let gradientNode = GradientNodeFactory.makeNoisyGradientNode(
        size: self.size,
        cornerRadius: 12,
        colors: [.black, .red],
        angleDegree: 135
      )
      gradientNode.position = CGPoint(x: 0, y: 0)
      cardContainer.addChild(gradientNode)
    case .club, .spade:
      let gradientNode = GradientNodeFactory.makeNoisyGradientNode(
        size: self.size,
        cornerRadius: 7,
        colors: [
          UIColor(hex: "#8F56ED")!,
          UIColor(hex: "#776BDF")!,
          UIColor(hex: "#6480E1")!,
          UIColor(hex: "#6480E1")!,
          UIColor(hex: "#776BDF")!,
          UIColor(hex: "#8F56ED")!,
        ],
        angleDegree: 45,
        locations: [0.0, 0.1, 0.3, 0.7, 0.9, 1.0]
      )
      // 140, 84, 220
      gradientNode.position = CGPoint(x: 0, y: 0)
      cardContainer.addChild(gradientNode)
    }
    
    
    let neonBorder = SKShapeNode(rectOf: size, cornerRadius: 7)
    neonBorder.strokeColor = .cyan
    neonBorder.lineWidth = 0.5
    neonBorder.glowWidth = 1
    // neonBorder.zPosition = 1
    cardContainer.addChild(neonBorder)
    
    switch displayMode {
    case .fullFront:
      let label = SKLabelNode(text: "\(card.rankString) \(card.suit.symbol)")
      label.fontSize = 14
      label.fontColor = .white
      label.verticalAlignmentMode = .center
      label.horizontalAlignmentMode = .center
      label.position = CGPoint(x: 0, y: 0)
      // label.zPosition = 2
      label.fontName = "SFProText-Medium"
      cardContainer.addChild(label)
    case .partialFront:
      let label = SKLabelNode(text: "\(card.rankString) \(card.suit.symbol)")
      label.fontSize = 10
      label.fontColor = card.suit.color == .red ? .red : .black
      label.verticalAlignmentMode = .top
      label.horizontalAlignmentMode = .left
      label.position = CGPoint(x: -self.size.width / 2 + 5, y: self.size.height / 2 - 5)
      label.zPosition = 1
      addChild(label)
      
    case .back:
      let texture = SKTexture(image: .cardBackCyber1)
      let pattern = SKSpriteNode(texture: texture)
      pattern.size = CGSize(
        width: size.width - 2,
        height: size.height - 2
      )
      pattern.position = .zero
      cardContainer.addChild(pattern)
    }
    
    addChild(cardContainer)
  }
  
  private func returnToOriginalPosition() {
    isDragging = false
    
    let moveBack = SKAction.move(to: originalDragPosition, duration: 0.3)
    let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
    let group = SKAction.group([moveBack, scaleDown])
    
    run(group)
    
    zPosition = if let originalZPosition {
      originalZPosition
    } else {
      1
    }
  }
}

extension CardNode {
  // MARK: - Touch events (overrided)
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    guard let parent else { return }
    
    let touchLocation = touch.location(in: parent)
    
    delegate?.didClickCard(self, touchPoint: touchLocation) {
      setupUI()
    } animSlideToWasteHandler: {
      isDragging = false
      // 옆으로 이동하는 애니메이션
      let moveRight = SKAction.moveBy(x: width + 20, y: 0, duration: 0.25)
      run(moveRight)
    } dragStartHandler: {
      isDragging = true
    }
    
    if isDragging {
      originalDragPosition = position
      dragOffset = CGPoint(
        x: touchLocation.x - position.x,
        y: touchLocation.y - position.y
      )
      
      // 드래그 시작 시 카드를 맨 앞으로
      originalZPosition = zPosition
      zPosition = 100
      
      // 드래그 시작 애니메이션 (선택사항)
      let scaleUp = SKAction.scale(to: 1.1, duration: 0.1)
      run(scaleUp)
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard isDragging, let touch = touches.first else { return }
    
    let touchLocation = touch.location(in: self.parent!)
    
    // 드래그 오프셋을 고려해서 위치 업데이트
    position = CGPoint(
      x: touchLocation.x - dragOffset.x,
      y: touchLocation.y - dragOffset.y
    )
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard isDragging, let touch = touches.first else { return }
    guard let parent else { return }
    
    isDragging = false
    
    // 드래그 종료 애니메이션
    let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
    run(scaleDown)
    
    // zPosition 원래대로
    zPosition = originalZPosition ?? 0

    // 여기서 드롭 존 체크나 원래 위치로 복귀 로직 추가 가능
    delegate?.checkDropZone(self, touchPoint: touch.location(in: parent), backToOriginHandler: returnToOriginalPosition)
  }
}

// MARK: - for preview only

class CardPreviewScene: SKScene {
  
  override func didMove(to view: SKView) {
    super.didMove(to: view)
    // anchor point 설정
    anchorPoint = CGPoint(x: 0.5, y: 0.5)
    
    backgroundColor = .cyan
    size = CGSize(width: 500, height: 500)
    setupBackground()
    setupCards()
  }
  
  func setupBackground() {
    let backgroundTexture = SKTexture(image: .cyberpunk1)
    let backgroundNode = SKSpriteNode(texture: backgroundTexture)
    backgroundNode.position = .zero
    backgroundNode.size = self.size
    backgroundNode.zPosition = -1
    
    addChild(backgroundNode)
  }
  
  func setupCards() {
    let card = Card(suit: .heart, rank: 12) // 예: Q♥
    let cardNode = CardNode(card: card, displayMode: .fullFront)
    cardNode.position = CGPoint(x: 0, y: 200)
    addChild(cardNode)
    
    // 테스트용 카드들 생성
    let card1 = Card(suit: .heart, rank: 1)
    let cardNode1 = CardNode(card: card1, displayMode: .partialFront)
    cardNode1.position = CGPoint(x: 0, y: 50)
    addChild(cardNode1)
    
    let card2 = Card(suit: .diamond, rank: 7)
    let cardNode2 = CardNode(card: card2, displayMode: .back)
    cardNode2.position = CGPoint(x: 0, y: 30)
    addChild(cardNode2)
    
    let card3 = Card(suit: .spade, rank: 13)
    let cardNode3 = CardNode(card: card3, displayMode: .partialFront)
    cardNode3.position = CGPoint(x: 100, y: 50)
    addChild(cardNode3)
    
    let card4 = Card(suit: .heart, rank: 12)
    let cardNode4 = CardNode(card: card4, displayMode: .partialFront)
    cardNode4.position = CGPoint(x: 100, y: 30)
    addChild(cardNode4)
    
    let card5 = Card(suit: .club, rank: 11)
    let cardNode5 = CardNode(card: card5, displayMode: .fullFront)
    cardNode5.position = CGPoint(x: 100, y: 10)
    addChild(cardNode5)
  }
}

#Preview {
  SpriteView(scene: CardPreviewScene())
    .frame(width: 500, height: 500) 
    .background(.gray.opacity(0.2))
    .cornerRadius(5)
    .ignoresSafeArea()
}
