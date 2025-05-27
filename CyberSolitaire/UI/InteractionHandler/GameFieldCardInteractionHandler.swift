//
//  GameFieldCardInteractionHandler.swift
//  CyberSolitaire
//
//  Created by 윤범태 on 5/26/25.
//

import SpriteKit

class GameFieldCardInteractionHandler: CardNodeDelegate {
  // var deckDropZones: [CGRect] = []
  var viewModel: GameFieldSceneViewModel?
  private var zPos = 2
  
  init() {}
  
  func checkDropZone(
    _ cardNode: CardNode,
    touchPoint: CGPoint,
    returnHandler: (() -> Void)
  ) {
    let card = cardNode.card
    
    guard let viewModel else {
      return
    }
    
    if let stackIndex = viewModel.tableauStacksIndex(containing: touchPoint) {
      // 움직인 카드가 어디 스택에 있었는지에 대한 스택 인덱스
      guard let beforeStackIndex = viewModel.tableauStacksIndex(containingCard: card) else {
        returnHandler()
        return
      }
      // ??: 원래 있던 스택에서 카드는 몇 번째 인덱스에 있는가?
      guard let currentIndexInStack = viewModel.tableauStacks[beforeStackIndex].cards.firstIndex(where: { card.value == $0.value }) else {
        returnHandler()
        return
      }
      // ??: 카드가 탑에 있을 때에만 이동 가능
      guard viewModel.tableauStacks[beforeStackIndex].topCard == card else {
        returnHandler()
        return
      }
      
      if viewModel.tableauStacks[stackIndex].canStack(card) {
        
        // 카드를 놓을 때 그 카드보다 zPos가 한 단계 더 높아야 함
        if let topCard = viewModel.tableauStacks[stackIndex].topCard,
           let topCardNode = cardNode.scene?.childNode(withName: topCard.dataDescription) {
          cardNode.zPosition = topCardNode.zPosition + 1
        }
        
        viewModel.tableauStacks[stackIndex].addCards([card])
        viewModel.tableauStacks[beforeStackIndex].removeCards(exactly: currentIndexInStack)
        viewModel.tableauStacks[stackIndex].faceUpCount += 1
        if let position = viewModel.tableauStackLocation(in: stackIndex) {
          cardNode.position = position
        }
      } else {
        returnHandler()
      }
    }
    
    else if let stackIndex = viewModel.foundationStackIndex(containing: touchPoint),
            viewModel.canPlaceCard(card, in: stackIndex) {
      // TODO: - 한 덩어리: 원래 있던 위치에서 자신이 탑인가?
      guard let beforeStackIndex = viewModel.tableauStacksIndex(containingCard: card) else {
        returnHandler()
        return
      }
      // ??: 카드가 탑에 있을 때에만 이동 가능
      guard viewModel.tableauStacks[beforeStackIndex].topCard == card else {
        returnHandler()
        return
      }
      // =============================== //
    
      if let postion = viewModel.foundationStackLocation(in: stackIndex) {
        cardNode.position = postion
        viewModel.placeCard(card, in: stackIndex)
        viewModel.tableauStacks[beforeStackIndex].cards.removeLast()
      }
    }
    
    else if let index = viewModel.foundationStackIndex(containingCard: card) {
      // TODO: - 삭제하고, 스택으로 돌려보냄
      viewModel.remove(card: card, from: index)
    }
    
    else {
      // 무효한 드롭 - 원래 위치로 복귀
      returnHandler()
    }
  }
  
  
  func didClickCard(
    _ cardNode: CardNode,
    touchPoint: CGPoint,
    redrawHandler: () -> Void
  ) {
    let card = cardNode.card
    
    guard let viewModel else {
      return
    }
    
    // TODO: - 한 덩어리: 원래 있던 위치에서 자신이 탑인가?
    guard let beforeStackIndex = viewModel.tableauStacksIndex(containingCard: card) else {
      return
    }
    // ??: 카드가 탑에 있을 때에만 이동 가능
    guard viewModel.tableauStacks[beforeStackIndex].topCard == card else {
      // print(viewModel.tableauStacks[beforeStackIndex].topCard, card)
      return
    }
    // =============================== //
    
    
    // 임시: 카드 뒤집혔으면 앞면으로
    if cardNode.displayMode == .back {
      cardNode.displayMode = .fullFront
      
      redrawHandler()
    }
  }
}
