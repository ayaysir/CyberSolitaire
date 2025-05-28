//
//  GameFieldSceneViewModel+CardNodeDelegate.swift
//  CyberSolitaire
//
//  Created by 윤범태 on 5/29/25.
//

import Foundation

/*
 TODO:
 
 - 리팩터
   - ✔️ 뷰모델 Optional로 굳이 할 필요 없으면 Non-optional로 변경 => 아예 InteractionHandler를 없애고 ViewModel이랑 합침
 - Tableau 에서 여러 카드 스택 한꺼번에 옮기기
   - 예) [~~~][J][10][9] 인 경우 J를 드래그하면 아래 10, 9도 같이 움직이게
 - Tableau에서 뒷면 상태인 카드 드래그해도 요지부동하게
 - Stock Pile에서 카드 하나(또는 3개씩) 확인할 수 있게: waste 분리
 */

extension GameFieldSceneViewModel: CardNodeDelegate {
  func checkDropZone(
    _ cardNode: CardNode,
    touchPoint: CGPoint,
    returnHandler: (() -> Void)
  ) {
    let card = cardNode.card
    
    // 카드가 tableau로 옮겨졌을 때
    if let stackIndex = tableauStacksIndex(containing: touchPoint) {
      
      if stockStacks.contains(card), tableauStacks[stackIndex].canStack(card)  {
        stackCardOnTableau(cardNode, stackIndex: stackIndex) { [unowned self] in
          stockStacks.removeLast()
        }
        
        return
      }
      
      // 움직인 카드가 어디 스택에 있었는지에 대한 스택 인덱스
      guard let beforeStackIndex = tableauStacksIndex(containingCard: card) else {
        returnHandler()
        return
      }
      // ??: 원래 있던 스택에서 카드는 몇 번째 인덱스에 있는가?
      guard let currentIndexInStack = tableauStacks[beforeStackIndex].cards.firstIndex(where: { card.value == $0.value }) else {
        returnHandler()
        return
      }
      // ??: 카드가 탑에 있을 때에만 이동 가능
      guard tableauStacks[beforeStackIndex].topCard == card else {
        returnHandler()
        return
      }
      
      if tableauStacks[stackIndex].canStack(card) {
        stackCardOnTableau(cardNode, stackIndex: stackIndex) { [unowned self] in
          tableauStacks[beforeStackIndex].removeTopCard()
        }
      } else {
        returnHandler()
      }
    }
    
    // 카드가 Foundation으로 옮겨졌을 때
    else if let stackIndex = foundationStackIndex(containing: touchPoint),
            canPlaceCard(card, in: stackIndex) {
      if stockStacks.contains(card) {
        stackCardOnFoundation(cardNode, stackIndex: stackIndex) { [unowned self] in
          stockStacks.removeLast()
        }
        
        return
      }
      
      // TODO: - 한 덩어리: 원래 있던 위치에서 자신이 탑인가?
      guard let beforeStackIndex = tableauStacksIndex(containingCard: card) else {
        returnHandler()
        return
      }
      // ??: 카드가 탑에 있을 때에만 이동 가능
      guard tableauStacks[beforeStackIndex].topCard == card else {
        returnHandler()
        return
      }
      // =============================== //
    
      stackCardOnFoundation(cardNode, stackIndex: stackIndex) { [unowned self] in
        tableauStacks[beforeStackIndex].cards.removeLast()
      }
    }
    
    else if let index = foundationStackIndex(containingCard: card) {
      // TODO: - 삭제하고, 스택으로 돌려보냄
      remove(card: card, from: index)
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
    
    if stockStacks.contains(card) {
      if cardNode.displayMode == .back {
        cardNode.displayMode = .fullFront
        
        redrawHandler()
      }
      return
    }
    
    // TODO: - 한 덩어리: 원래 있던 위치에서 자신이 탑인가?
    guard let beforeStackIndex = tableauStacksIndex(containingCard: card) else {
      return
    }
    // ??: 카드가 탑에 있을 때에만 이동 가능
    guard tableauStacks[beforeStackIndex].topCard == card else {
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

extension GameFieldSceneViewModel {
  func stackCardOnTableau(
    _ cardNode: CardNode,
    stackIndex: Int,
    deleteCardHandler: VoidCallback? = nil
  ) {
    let card = cardNode.card
    
    // 카드를 놓을 때 그 카드보다 zPos가 한 단계 더 높아야 함
    if let topCard = tableauStacks[stackIndex].topCard,
       let topCardNode = cardNode.scene?.childNode(withName: topCard.dataDescription) {
      cardNode.zPosition = topCardNode.zPosition + 1
    }
    
    tableauStacks[stackIndex].addCards([card])
    // viewModel.tableauStacks[beforeStackIndex]
    deleteCardHandler?()
    
    tableauStacks[stackIndex].faceUpCount += 1
    if let position = tableauStackLocation(in: stackIndex) {
      cardNode.position = position
    }
  }
  
  func stackCardOnFoundation(
    _ cardNode: CardNode,
    stackIndex: Int,
    deleteCardHandler: VoidCallback? = nil
  ) {
    let card = cardNode.card
    
    if let postion = foundationStackLocation(in: stackIndex) {
      cardNode.position = postion
      placeCard(card, in: stackIndex)
      deleteCardHandler?()
    }
  }
}

