//
//  TableauStack.swift
//  CyberSolitaire
//
//  Created by 윤범태 on 5/27/25.
//

import Foundation

struct TableauStack: Codable {
  /// 카드 스택 (맨 마지막이 보이는 카드)
  var cards: [Card] = []
  
  /// 카드가 이 열에 쌓일 수 있는지 판단
  var topCard: Card? {
    cards.last
  }
  
  /// 뒷면으로 놓인 카드를 제외한 앞면 카드 개수
  /// - 게임 진행 중, 특정 카드(top card)를 밑으로 앞면 스택이 쌓일 수 있는데 그것의 개수를 의미하는 것
  /// - 예: [-][-][-][R10][B9][R8] 인 경우 faceUpCount는 3
  var faceUpCount: Int = 0
  
  var dropZone: CGRect?
  
  /// 카드가 이 열에 쌓일 수 있는지 판단
  /// - Parameters:
  ///   - card: 쌓고자 하는 카드(의 가장 윗카드?)
  func canStack(_ card: Card) -> Bool {
    guard let topCard else {
      print("top card is nil")
      return card.rank == 13 // K일 때만 빈 자리에 올 수 있음
    }
    
    print(!card.isSameColor(as: topCard), card.rank, topCard.rank)
    return !card.isSameColor(as: topCard) && card.rank == topCard.rank - 1
  }
  
  /// 카드를 인덱스에서부터 뽑아내기 (한 장 또는 여러 장)
  func extractCards(from index: Int) -> [Card] {
    Array(cards.suffix(from: index))
  }
  
  func cardIndex(of card: Card) -> Int? {
    cards.firstIndex(of: card)
  }
  
  /// cards 배열에서 특정 카드가 뒤에서부터 몇 번째인지 반환 (1부터 시작)
  /// - Returns: cards.last면 1, 그 앞이면 2, ... 못 찾으면 nil
  func distanceFromEnd(of card: Card) -> Int? {
    guard let index = cards.firstIndex(of: card) else { return nil }
    return cards.count - index
  }
  
  /// 카드 추가
  /// - 한 개일수도 있고, 여러 개일수도 있음
  mutating func addCards(_ newCards: [Card]) {
    cards.append(contentsOf: newCards)
  }
  
  /// 카드 제거
  mutating func removeCards(from index: Int) {
    let removeCount = cards.count - index - 1
    cards.removeSubrange(index..<cards.count)
    // 뒷면을 뒤집는 로직은 별도로 처리
    
    // faceup 카운트 조절
    faceUpCount -= removeCount
  }
  
  mutating func removeCards(from targetCards: [Card]) {
    // cards에 targetCards에 있는 카드가 있다면 지우기
    cards.removeAll { targetCards.contains($0) }
    // faceup 카운트 조절
    faceUpCount -= targetCards.count
  }
  
  mutating func removeCard(exactly index: Int) {
    cards.remove(at: index)
    
    // faceup 카운트 조절
    faceUpCount -= 1
  }
  
  mutating func removeTopCard() {
    cards.removeLast()
    
    // faceup 카운트 조절
    faceUpCount -= 1
  }
}
