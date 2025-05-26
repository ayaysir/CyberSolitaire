//
//  GameFieldSceneViewModel.swift
//  CyberSolitaire
//
//  Created by 윤범태 on 5/26/25.
//

import Foundation
import BGSMM_DevKit

final class GameFieldSceneViewModel: ObservableObject {
  @Published var cards: [Card] = []
  @Published var decks: [Deck] = (1...4).map { Deck(index: $0) }
}

extension GameFieldSceneViewModel {
  /// 특정 드롭존에 해당하는 덱의 인덱스(zero-based)를 반환
  func deckIndex(containing point: CGPoint) -> Int? {
    decks.firstIndex { $0.dropZone?.contains(point) == true }
  }
  
  /// 카드가 해당 덱에 쌓일 수 있는지 판단 (룰 적용)
  func canPlaceCard(_ card: Card, in deckIndex: Int) -> Bool {
    guard let topCard = decks[safe: deckIndex]?.cards.last else {
      return card.rank == 1
    }
    
    // 마지막 카드 확인
    return card.suit == topCard.suit && card.rank == topCard.rank + 1
  }
  
  /// 특정 인덱스의 덱에 카드를 추가
  func placeCard(_ card: Card, inDeckAt index: Int) {
    guard decks.indices.contains(index) else { return }
    decks[index].cards.append(card)
    removeFromMainCards(card)
  }
  
  /// 메인 카드 배열에서 제거
  func removeFromMainCards(_ card: Card) {
    if let i = cards.firstIndex(of: card) {
      cards.remove(at: i)
    }
  }
  
  /// 덱의 midX, midY 포인트 반환
  func deckLocation(inDeckAt index: Int) -> CGPoint? {
    guard decks.indices.contains(index) else { return nil }
    guard let dropZone = decks[index].dropZone else {
      return nil
    }
    
    return CGPoint(x: dropZone.midX, y: dropZone.midY)
  }
  
  /// 카드가 포함된 덱의 인덱스를 반환 (없으면 nil)
  /// - Returns: 덱 번호, `nil`인 경우 덱에 속해있지 않음
  func deckIndex(containingCard card: Card) -> Int? {
    return decks.firstIndex { $0.cards.contains(card) }
  }
  
  /// 카드가 속한 덱에서 해당 카드를 제거
  func removeCardFromContainingDeck(_ card: Card) {
    guard let deckIndex = deckIndex(containingCard: card) else {
      return
    }
    
    remove(card: card, fromDeckAt: deckIndex)
  }
  
  /// 카드가 속한 덱에서 해당 카드를 제거
  func remove(card: Card, fromDeckAt index: Int) {
    guard decks.indices.contains(index) else { return }
    if let cardIndex = decks[index].cards.firstIndex(of: card) {
      decks[index].cards.remove(at: cardIndex)
    }
  }
}
