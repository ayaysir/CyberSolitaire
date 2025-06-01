//
//  GameFieldSceneViewModel.swift
//  CyberSolitaire
//
//  Created by 윤범태 on 5/26/25.
//

import Foundation

final class GameFieldSceneViewModel: ObservableObject {
  @Published var cards: [Card] = []
  @Published var foundationStacks: [FoundationStack] = Array(repeating: .init(), count: 4)
  @Published var tableauStacks: [TableauStack] = Array(repeating: .init(), count: 7)
  @Published var stockStacks: [Card] = []
  @Published var wasteStacks: [Card] = []
  
  @Published var gameCount = 0
  
  // var movingCardChunks: [Card]? = nil
  
  var wasteIndex = 0
}

extension GameFieldSceneViewModel {
  
  func setNewCards() {
    cards = []
    foundationStacks = Array(repeating: .init(), count: 4)
    tableauStacks = Array(repeating: .init(), count: 7)
    stockStacks = []
    wasteStacks = []
    
    cards = Card.Suit.allCases.map { suit in
      (1...13).map { Card(suit: suit, rank: $0) }
    }
    .flatMap { $0 }
    .shuffled()
    
    // 카드가 충분한지 확인
    // guard cards.count >= 28 else { return }
    
    var cardIndex = 0
    
    for i in tableauStacks.indices {
      let numberOfCards = i + 1
      let stackCards = Array(cards[cardIndex..<cardIndex + numberOfCards])
      tableauStacks[i] = TableauStack(cards: stackCards, faceUpCount: 1)
      cardIndex += numberOfCards
    }
    
    stockStacks = Array(cards[cardIndex...])
    print("init stockStacks:", stockStacks.count)
  }
  
  // func setTableauStacks() {
 
  // }
  
  func tableauStacksIndex(containingCard card: Card) -> Int? {
    for i in tableauStacks.indices {
      if tableauStacks[i].cards.contains(card) {
        return i
      }
    }
    
    return nil
  }
  
  func tableauStacksIndex(containing point: CGPoint) -> Int? {
    tableauStacks.firstIndex { $0.dropZone?.contains(point) == true }
  }
  
  func tableauStackLocation(in stackIndex: Int, movingCardsCount: Int = 1) -> CGPoint? {
    guard tableauStacks.indices.contains(stackIndex) else { return nil }
    guard let dropZone = tableauStacks[stackIndex].dropZone else {
      return nil
    }
    // count 5, 1 = 5
    // count 5, 2 = 4
    // return CGPoint(x: dropZone.midX, y: 200 - 50 * CGFloat(tableauStacks[stackIndex].cards.count - 1 - (movingCardsCount - 1) ))
    return .init(
      x: dropZone.midX,
      // TODO: - movingCardsCounts 기준 통일하기
      y: 200 - UI_VERTICAL_CARD_SPACING * CGFloat(tableauStacks[stackIndex].cards.count - movingCardsCount + 1)
    )
  }
  
  func removeCardsFromTableau() {
    
  }
}

extension GameFieldSceneViewModel {
  /// 특정 드롭존에 해당하는 파운데이션 스택의 인덱스(zero-based)를 반환
  func foundationStackIndex(containing point: CGPoint) -> Int? {
    foundationStacks.firstIndex { $0.dropZone?.contains(point) == true }
  }
  
  /// 카드가 해당 파운데이션 스택에 쌓일 수 있는지 판단 (룰 적용)
  func canPlaceCardToFoundationStack(_ card: Card, in stackIndex: Int) -> Bool {
    guard foundationStacks.indices.contains(stackIndex) else { return false }
    guard let topCard = foundationStacks[stackIndex].cards.last else {
      return card.rank == 1
    }
    
    // 마지막 카드 확인
    return card.suit == topCard.suit && card.rank == topCard.rank + 1
  }
  
  /// 특정 인덱스의 파운데이션 스택에 카드를 추가
  func placeCard(_ card: Card, in stackIndex: Int) {
    guard foundationStacks.indices.contains(stackIndex) else { return }
    foundationStacks[stackIndex].cards.append(card)
    removeFromMainCards(card)
  }
  
  /// 메인 카드 배열에서 제거
  func removeFromMainCards(_ card: Card) {
    if let i = cards.firstIndex(of: card) {
      cards.remove(at: i)
    }
  }
  
  /// 파운데이션 스택의 midX, midY 포인트 반환
  func foundationStackLocation(in stackIndex: Int) -> CGPoint? {
    guard foundationStacks.indices.contains(stackIndex) else { return nil }
    guard let dropZone = foundationStacks[stackIndex].dropZone else {
      return nil
    }
    
    return CGPoint(x: dropZone.midX, y: dropZone.midY)
  }
  
  /// 카드가 포함된 파운데이션 스택의 인덱스를 반환 (없으면 `nil`)
  func foundationStackIndex(containingCard card: Card) -> Int? {
    return foundationStacks.firstIndex { $0.cards.contains(card) }
  }
  
  /// 카드가 속한 파운데이션 스택에서 해당 카드를 제거
  func removeCardFromContainingFoundationStack(_ card: Card) {
    guard let stackIndex = foundationStackIndex(containingCard: card) else {
      return
    }
    
    remove(card: card, from: stackIndex)
  }
  
  /// 카드가 속한 파운데이션 스택에서 해당 카드를 제거
  func remove(card: Card, from stackIndex: Int) {
    guard foundationStacks.indices.contains(stackIndex) else { return }
    
    if let cardIndex = foundationStacks[stackIndex].cards.firstIndex(of: card) {
      foundationStacks[stackIndex].cards.remove(at: cardIndex)
    }
  }
}

extension GameFieldSceneViewModel {
  func isCardInStockStacks(_ card: Card) -> Bool {
    stockStacks.contains(card)
  }
  
  func isTopCardInStock(_ card: Card) -> Bool {
    stockStacks.last == card
  }
  
  func removeCardFromStockStacks(_ card: Card) {
    stockStacks.removeAll { $0 == card }
  }
  
  /// 카드가 움직일 수 있는 탑에 있는 카드라면, 해당 Tableau 스택의 인덱스를 반환. 아니라면 nil
  func tableauIndex(topCardOnTableauStack card: Card) -> Int? {
    guard let index = tableauStacksIndex(containingCard: card),
          tableauStacks[index].topCard == card
    else {
      return nil
    }
    
    return index
  }
  
  func isTopCardOnTableauStack(_ card: Card) -> Bool {
    tableauIndex(topCardOnTableauStack: card) != nil
  }
}

extension GameFieldSceneViewModel {
  func addCardFromStockToWaste() {
    guard stockStacks.count > 0 else {
      return
    }
    
    let card = stockStacks.removeLast()
    wasteStacks.append(card)
  }
  
  func removeTopCardFromWasteStack() {
    guard wasteStacks.count > 0 else {
      return
    }
    
    wasteStacks.removeLast()
  }
  
  func setStockFromRemainWaste() {
    stockStacks = wasteStacks.reversed()
    wasteStacks = []
  }
  
  func isCardInWasteStacks(_ card: Card) -> Bool {
    wasteStacks.contains(card)
  }
  
  // TODO: - isAvailableCardInWaste 만들기: 3개 카드 대비
  func isTopCardInWaste(_ card: Card) -> Bool {
    wasteStacks.last == card
  }
  
  func extractCards(_ card: Card, fromTableauStackIndex tableauIndex: Int) -> [Card]? {
    // RO: Read Only
    let tableauStackRO = tableauStacks[tableauIndex]
    let faceUpCount = tableauStackRO.faceUpCount
    
    guard tableauStackRO.cards.contains(card),
          let cardIndex = tableauStackRO.cardIndex(of: card),
          let distanceFromEnd = tableauStackRO.distanceFromEnd(of: card) else {
      print("tableauStackRO에 카드가 없습니다.")
      return nil
    }
    
    guard faceUpCount >= distanceFromEnd else {
      print("faceUpCount >= distanceFromEnd", faceUpCount, distanceFromEnd)
      return nil
    }
    
    return tableauStackRO.extractCards(from: cardIndex)
  }
}
