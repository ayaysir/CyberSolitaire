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
    
    if let index = viewModel.deckIndex(containing: touchPoint),
       viewModel.canPlaceCard(card, in: index) {
      viewModel.placeCard(card, inDeckAt: index)
      viewModel.removeFromMainCards(card)
      
      if let postion = viewModel.deckLocation(inDeckAt: index) {
        cardNode.position = postion
      }
    }
    
    // 예시: y > 0 영역이 드롭 존이라고 가정
    else if -250...250 ~= touchPoint.y {
      // 유효한 드롭 - 현재 위치 유지
      print("카드가 기본 드롭 존에 놓였습니다: \(card.rankString) \(card.suit.symbol)")
      returnHandler()
    } else {
      // 무효한 드롭 - 원래 위치로 복귀
      returnHandler()
    }
  }
}
