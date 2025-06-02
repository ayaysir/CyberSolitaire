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
  let DEBUG_showZPos = false
  
  var card: Card
  var width: CGFloat = 50
  var displayMode: Card.DisplayMode
  var dropZone: CGRect?
  var isGroupLeader: Bool = false
  private var originalZPosition: CGFloat?
  
  weak var delegate: CardNodeDelegate?
  
  // Drag 프로퍼티
  /// true인 경우 touchMoved, Ended 이벤트 지속, false인 경우 began으로 종료
  private var isDragging = false
  private var touchStartPoint: CGPoint?
  private let dragThreshold: CGFloat = 8
  private var isActuallyMoved = false
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
    childNode(withName: "cardContainer")?.removeFromParent()
    
    let cardContainer = SKNode()
    cardContainer.name = "cardContainer"
    
    switch card.suit {
    case .heart, .diamond:
      let gradientNode = GradientNodeFactory.makeNoisyGradientNode(
        size: self.size,
        cornerRadius: 7,
        colors: [
          UIColor(hex: "#f18bc9")!,
          UIColor(hex: "#f4b0c8")!,
          UIColor(hex: "#f4bbc9")!,
          UIColor(hex: "#f4bbc9")!,
          UIColor(hex: "#f4b0c8")!,
          UIColor(hex: "#f18bc9")!,
        ],
        angleDegree: 45,
        locations: [0.0, 0.1, 0.3, 0.7, 0.9, 1.0]
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
    
    switch displayMode {
    case .fullFront:
      let PADDING: CGFloat = 2.5
      // 왼쪽 상단 숫자
      let topLabel = SKLabelNode(text: "\(card.rankString)")
      topLabel.fontSize = 18
      topLabel.fontColor = switch card.suit {
      case .heart, .diamond:
        UIColor(hex: "f11c5c")!
      case .club, .spade:
        UIColor(hex: "141541")!
      }
      topLabel.fontName = "Courier"
      topLabel.verticalAlignmentMode = .top
      topLabel.horizontalAlignmentMode = .left
      topLabel.numberOfLines = 1
      topLabel.preferredMaxLayoutWidth = 20
      topLabel.lineBreakMode = .byWordWrapping
      topLabel.position = CGPoint(
        x: -self.size.width / 2 + PADDING,
        y: self.size.height / 2 - PADDING
      )
      
      let topCode = topLabel.copy() as! SKLabelNode
      topCode.fontSize = 18
      topCode.text = card.suit.symbolText
      topCode.position = CGPoint(
        x: -self.size.width / 2 + PADDING,
        y: topLabel.position.y - 14
      )
      
      let labels = SKNode()
      labels.addChild(topLabel)
      labels.addChild(topCode)
      cardContainer.addChild(labels)

      // 오른쪽 하단 숫자 (뒤집기)
      
      let rotatedLabels = labels.copy() as! SKNode
      rotatedLabels.zRotation = .pi
      cardContainer.addChild(rotatedLabels)

      // 가운데 이모지
      let centerLabel = SKLabelNode(text: card.suit.symbolEmoji)
      centerLabel.fontSize = 20
      centerLabel.fontColor = .white
      centerLabel.fontName = "SFProText-Medium"
      centerLabel.verticalAlignmentMode = .center
      centerLabel.horizontalAlignmentMode = .center
      centerLabel.position = CGPoint(x: 0, y: 0)
      cardContainer.addChild(centerLabel)
      
      // border
      let neonBorder = SKShapeNode(rectOf: size, cornerRadius: 7)
      neonBorder.strokeColor = switch card.suit {
        case .heart, .diamond:
          // UIColor(hex: "#f5b7ce")!
        UIColor(hex: "#ff8786")!
        case .club, .spade:
          .cyan
      }
      neonBorder.lineWidth = 1
      neonBorder.glowWidth = 1
      // neonBorder.zPosition = 1
      cardContainer.addChild(neonBorder)
    case .partialFront:
      let label = SKLabelNode(text: "\(card.rankString) \(card.suit.symbolEmoji)")
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
      
      let neonBorder = SKShapeNode(rectOf: size, cornerRadius: 7)
      neonBorder.strokeColor = UIColor(hex: "9b28bf")!
      neonBorder.lineWidth = 1
      neonBorder.glowWidth = 1
      cardContainer.addChild(neonBorder)
    }
    
    addChild(cardContainer)
    DEBUG_drawZPos()
  }
  
  private func returnToOriginalPosition() {
    let moveBack = SKAction.move(to: originalDragPosition, duration: 0.3)
    let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
    let group = SKAction.group([moveBack, scaleDown])
    
    run(group)
    // zPosition 원래대로
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [unowned self] in
      zPosition = originalZPosition ?? 0
      originalZPosition = nil
      DEBUG_drawZPos()
    }
  }
  
  private func successDrop(_ zPos: Int?) {}
  
  private func cardGroupMoveCancelled() {
    
  }
  
  func DEBUG_drawZPos() {
    guard DEBUG_showZPos else {
      return
    }
    // DEBUG
    if let cardContainer = childNode(withName: "cardContainer") {
      if let zPosNode = cardContainer.childNode(withName: "DEBUG_zPosition") {
        zPosNode.removeFromParent()
      }
      
      // DEBUG 용
      let zLabel = SKLabelNode(text: "z:\(self.zPosition)")
      zLabel.fontSize = 8
      zLabel.fontColor = .yellow
      zLabel.verticalAlignmentMode = .bottom
      zLabel.horizontalAlignmentMode = .left
      zLabel.position = CGPoint(x: -3, y: 25)
      zLabel.fontName = "Courier"
      zLabel.name = "DEBUG_zPosition"
      cardContainer.addChild(zLabel)
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
    } multipleDragStartHandler: {
      
    }
    
    if isDragging {
      originalDragPosition = position
      dragOffset = CGPoint(
        x: touchLocation.x - position.x,
        y: touchLocation.y - position.y
      )
      
      touchStartPoint = touchLocation
      
      // 드래그 시작 시 카드를 맨 앞으로
      originalZPosition = zPosition
      zPosition = 100_000
      
      // 드래그 시작 애니메이션 (선택사항)
      let scaleUp = SKAction.scale(to: 1.1, duration: 0.1)
      run(scaleUp)
    }
    
    DEBUG_drawZPos()
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard isDragging, let touch = touches.first, let touchStartPoint else { return }
    guard let parent else { return }
    
    let touchLocation = touch.location(in: parent)
    
    let distance = hypot(
      touchLocation.x - touchStartPoint.x,
      touchLocation.y - touchStartPoint.y
    )
    isActuallyMoved = distance > dragThreshold
    
    // 드래그 오프셋을 고려해서 위치 업데이트
    position = CGPoint(
      x: touchLocation.x - dragOffset.x,
      y: touchLocation.y - dragOffset.y
    )
    
    DEBUG_drawZPos()
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard isDragging, let touch = touches.first else { return }
    guard let parent else { return }
    
    isDragging = false
    
    if isActuallyMoved {
      // 여기서 드롭 존 체크나 원래 위치로 복귀 로직 추가 가능
      delegate?.checkDropZone(
        self,
        touchPoint: touch.location(in: parent),
        backToOriginHandler: returnToOriginalPosition,
        successDropHandler: successDrop,
        cardGroupMoveCancelledHandler: {}
      )
    } else if isGroupLeader {
      returnToOriginalPosition()
      delegate?.didCardGroupMoveCancelled(self, touchPoint: touch.location(in: parent))
    } else {
      returnToOriginalPosition()
      zPosition = originalZPosition ?? 0
    }
    
    isActuallyMoved = false
    // 드래그 종료 애니메이션
    let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
    run(scaleDown)
    // zPosition 조정: 딜리게이트에게 전권 부여
    
    DEBUG_drawZPos()
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
    let cardNode3 = CardNode(card: card3, displayMode: .fullFront)
    cardNode3.position = CGPoint(x: 100, y: 50)
    addChild(cardNode3)
    
    let card4 = Card(suit: .heart, rank: 12)
    let cardNode4 = CardNode(card: card4, displayMode: .fullFront)
    cardNode4.position = CGPoint(x: 100, y: 30)
    addChild(cardNode4)
    
    let card5 = Card(suit: .club, rank: 11)
    let cardNode5 = CardNode(card: card5, displayMode: .fullFront)
    cardNode5.position = CGPoint(x: 100, y: 10)
    addChild(cardNode5)
    
    let card6 = Card(suit: .club, rank: 13)
    let cardNode6 = CardNode(card: card6, displayMode: .fullFront)
    cardNode6.position = CGPoint(x: 0, y: -100)
    addChild(cardNode6)
    
    let card7 = Card(suit: .diamond, rank: 9)
    let cardNode7 = CardNode(card: card7, displayMode: .fullFront)
    cardNode7.position = CGPoint(x: 80, y: -100)
    addChild(cardNode7)
  }
}

#Preview {
  SpriteView(scene: CardPreviewScene())
    .frame(width: 500, height: 500) 
    .background(.gray.opacity(0.2))
    .cornerRadius(5)
    .ignoresSafeArea()
}
