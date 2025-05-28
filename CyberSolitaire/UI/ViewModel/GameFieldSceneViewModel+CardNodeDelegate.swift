//
//  GameFieldSceneViewModel+CardNodeDelegate.swift
//  CyberSolitaire
//
//  Created by 윤범태 on 5/29/25.
//

import Foundation

/*
 TODO:
 
 - ✔️ 리팩터
   - ✔️ 뷰모델 Optional로 굳이 할 필요 없으면 Non-optional로 변경 => 아예 InteractionHandler를 없애고 ViewModel이랑 합침
 - Tableau 에서 여러 카드 스택 한꺼번에 옮기기
   - 예) [~~~][J][10][9] 인 경우 J를 드래그하면 아래 10, 9도 같이 움직이게
 - Tableau에서 뒷면 상태인 카드 드래그해도 요지부동하게
 - Stock Pile에서 카드 하나(또는 3개씩) 확인할 수 있게: waste 분리
 */

extension GameFieldSceneViewModel: CardNodeDelegate {
  // MARK: - Delegate methods
  
  // 카드가 이동했을 때 카드의 드랍 존(도착지) 액션
  func checkDropZone(
    _ cardNode: CardNode,
    touchPoint: CGPoint,
    returnHandler: (() -> Void)
  ) {
    // case 1: 카드가 tableau로 옮겨졌을 때
    if let targetStackIndex = tableauStacksIndex(containing: touchPoint) {
      // case 1-1: 스톡 파일(왼쪽 상단)에서 테이블로 카드를 옮길 수 있음?
      if stockStacks.contains(cardNode.card) && tableauStacks[targetStackIndex].canStack(cardNode.card)  {
        // action: 스톡 파일의 카드를 새로운 스택[stackIndex]으로 옮기고 마지막 stock을 지움
        stackCardOnTableau(cardNode, stackIndex: targetStackIndex) { [unowned self] in
          stockStacks.removeLast()
        }
        
        return
      }
      // case 1-2: 테이블 스택에서 테이블 스택, 옮길 수 있는 경우
      if let originStackIndex = isTopCardOnTableauStack(cardNode.card),
         tableauStacks[targetStackIndex].canStack(cardNode.card) {
        // action: 이전 테이블 스택에서 새로운 테이블 스택으로 옮기고 이전 스택의 탑 카드를 지움
        stackCardOnTableau(cardNode, stackIndex: targetStackIndex) { [unowned self] in
          tableauStacks[originStackIndex].removeTopCard()
        }
        
        return
      }
    }
    
    // case 2: 카드가 Foundation으로 옮겨졌을 때
    if let targetStackIndex = foundationStackIndex(containing: touchPoint),
       canPlaceCardToFoundationStack(cardNode.card, in: targetStackIndex) {
      // case 2-1: 스톡 파일(왼쪽 상단)에서 Foundation로 카드를 옮길 수 있음?
      if stockStacks.contains(cardNode.card) {
        // action: 스톡 파일의 카드를 파운데이션 스택으로 옮기고 마지막 stock을 지움
        stackCardOnFoundation(cardNode, stackIndex: targetStackIndex) { [unowned self] in
          stockStacks.removeLast()
        }
        
        return
      }
      
      // case 2-2: 테이블 스택에서 파운데이션 스택, 옮길 수 있는 경우
      if let originStackIndex = isTopCardOnTableauStack(cardNode.card) {
        // action: 이전 테이블 스택에서 새로운 파운데이션 스택으로 옮기고 이전 스택의 탑 카드를 지움
        stackCardOnFoundation(cardNode, stackIndex: targetStackIndex) { [unowned self] in
          tableauStacks[originStackIndex].removeTopCard()
        }
        
        return
      }
    }
    
    returnHandler()
    return
  }
  
  // 카드를 클릭하기 시작했을 때 액션
  func didClickCard(
    _ cardNode: CardNode,
    touchPoint: CGPoint,
    redrawHandler: () -> Void
  ) {
    // 임시: 카드 뒤집혔으면 앞면으로
    if cardNode.displayMode == .back {
      cardNode.displayMode = .fullFront
      
      redrawHandler()
    }
  }
}


extension GameFieldSceneViewModel {
  // MARK: Utility funcs
  
  /// 카드가 움직일 수 있는 탑에 있는 카드라면, 해당 Tableau 스택의 인덱스를 반환. 아니라면 nil
  func isTopCardOnTableauStack(_ card: Card) -> Int? {
    guard let index = tableauStacksIndex(containingCard: card),
          tableauStacks[index].topCard == card
    else {
      return nil
    }
    
    return index
  }
}

extension GameFieldSceneViewModel {
  // MARK: - UI adjust funcs
  
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
