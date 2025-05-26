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
      return card.rank == 13 // K일 때만 빈 자리에 올 수 있음
    }
    
    return !card.isSameColor(as: topCard) && card.rank == topCard.rank - 1
  }
  
  /// 카드를 뽑아내기 (한 장 또는 여러 장)
  func extractCards(from index: Int) -> [Card] {
    Array(cards.suffix(from: index))
  }
  
  /// 카드 추가
  /// - 한 개일수도 있고, 여러 개일수도 있음
  mutating func addCards(_ newCards: [Card]) {
    cards.append(contentsOf: newCards)
  }
  
  /// 카드 제거
  mutating func removeCards(from index: Int) {
    cards.removeSubrange(index..<cards.count)
    // 뒷면을 뒤집는 로직은 별도로 처리
    
    // faceUpCount가 cards 배열의 총 개수보다 많아지지 않도록 강제로 조정한다.
    if faceUpCount > cards.count {
      faceUpCount = cards.count
    }
  }
  
  mutating func removeCards(exactly index: Int) {
    cards.remove(at: index)
    
    // faceUpCount가 cards 배열의 총 개수보다 많아지지 않도록 강제로 조정한다.
    if faceUpCount > cards.count {
      faceUpCount = cards.count
    }
  }
  
  mutating func removeTopCard() {
    cards.removeLast()
    
    // faceUpCount가 cards 배열의 총 개수보다 많아지지 않도록 강제로 조정한다.
    if faceUpCount > cards.count {
      faceUpCount = cards.count
    }
  }
}
