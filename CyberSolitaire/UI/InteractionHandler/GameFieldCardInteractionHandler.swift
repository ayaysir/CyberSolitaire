//
//  GameFieldCardInteractionHandler.swift
//  CyberSolitaire
//
//  Created by 윤범태 on 5/26/25.
//

import SpriteKit

class GameFieldCardInteractionHandler: CardNodeDelegate {
  var dropZone: CGRect?
  var viewModel: GameFieldSceneViewModel?
  
  init() {}
  
  init(dropZone: CGRect) {
    self.dropZone = dropZone
  }
  
  func checkDropZone(_ cardNode: CardNode, touchPoint: CGPoint, returnHandler: (() -> Void)) {
    let card = cardNode.card
    
    // 드롭 존 체크 로직 (예: 특정 영역에 드롭되었는지)
    if let dropZone, dropZone.contains(touchPoint) {
      print("카드가 설정 드롭 존에 놓였습니다: \(card.rankString) \(card.suit.symbol)")
      
      // 카드를 놓을 수 있으면 위치를 옮기고, 아니면 원래 있던 곳으로 리턴
      if canPlaceCardInDeck(card) {
        viewModel?.deck.append(card)
        
        // 원래 카드 배열에서 제거
        if let index = viewModel?.cards.firstIndex(of: card) {
          viewModel?.cards.remove(at: index)
        }
        
        // 덱 위치로 카드 이동
        cardNode.position = CGPoint(x: dropZone.midX, y: dropZone.midY)
      } else {
        returnHandler()
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
  
  func canPlaceCardInDeck(_ card: Card) -> Bool {
    guard let viewModel else {
      return false
    }
    
    // 덱이 비어있으면 A(1)만 놓을 수 있음
    if viewModel.deck.isEmpty {
      // return card.rank == 1
      // 임시: 덱이 비어있으면 먼저 이동하는 카드 우선
      return true
    }
    
    // 마지막 카드 확인
    guard let topCard = viewModel.deck.last else {
      return false
    }
    
    return card.suit == topCard.suit && card.rank == topCard.rank + 1
  }
}
