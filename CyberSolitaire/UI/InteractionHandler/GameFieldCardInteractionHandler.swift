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
      // print(stackIndex, viewModel.tableauStacks[stackIndex])
      guard let beforeStackIndex = viewModel.tableauStacksIndex(containingCard: card) else {
        print("beforeStackIndex is nil")
        returnHandler()
        return
      }
      guard let currentIndexInStack = viewModel.tableauStacks[beforeStackIndex].cards.firstIndex(where: { card.value == $0.value }) else {
        print("currentIndexInStack is nil")
        returnHandler()
        return
      }
      
      if viewModel.tableauStacks[stackIndex].canStack(card) {
        viewModel.tableauStacks[stackIndex].addCards([card])
        viewModel.tableauStacks[beforeStackIndex].removeCards(exactly: currentIndexInStack)
        
        cardNode.zPosition = CGFloat(zPos)
        zPos += 1
        if let position = viewModel.tableauStackLocation(in: stackIndex) {
          cardNode.position = position
        }
      } else {
        returnHandler()
      }
    }
    
    else if let stackIndex = viewModel.foundationStackIndex(containing: touchPoint),
       viewModel.canPlaceCard(card, in: stackIndex) {
      viewModel.placeCard(card, in: stackIndex)
      viewModel.removeFromMainCards(card)
    
      if let postion = viewModel.foundationStackLocation(in: stackIndex) {
        cardNode.position = postion
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
}
