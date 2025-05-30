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
 - ✔️ Tableau 에서 여러 카드 스택 한꺼번에 옮기기
   - 예) [~~~][J][10][9] 인 경우 J를 드래그하면 아래 10, 9도 같이 움직이게
 - ✔️ Tableau에서 뒷면 상태인 카드 드래그해도 요지부동하게
 - Stock Pile에서 카드 하나(또는 3개씩) 확인할 수 있게: waste 분리
 */

extension GameFieldSceneViewModel: CardNodeDelegate {
  // MARK: - Delegate methods
  
  // 카드가 이동했을 때 카드의 드랍 존(도착지) 액션
  func checkDropZone(
    _ cardNode: CardNode,
    touchPoint: CGPoint,
    backToOriginHandler: VoidCallback
  ) {
    // case 1: 카드가 ㅇㅇㅇ 에서 tableau로 옮겨졌을 때
    if let targetStackIndex = tableauStacksIndex(containing: touchPoint) {
      // case 1-1: 스톡 파일(왼쪽 상단)에서 테이블로 카드를 옮길 수 있음?
      if stockStacks.contains(cardNode.card) {
        if tableauStacks[targetStackIndex].canStack(cardNode.card) {
          // action: 스톡 파일의 카드를 새로운 스택[stackIndex]으로 옮기고 마지막 stock을 지움
          stackCardOnTableau(cardNode, stackIndex: targetStackIndex) { [unowned self] in
            removeCardFromStockStacks(cardNode.card)
          }
        } else {
          backToOriginHandler()
        }
        
        return
      }
      // case 1-2: 테이블 스택에서 테이블 스택, 옮길 수 있는 경우 (탑카드 1장)
      // print(isTopCardOnTableauStack(cardNode.card), tableauStacks[targetStackIndex].canStack(cardNode.card))
      // [6][5][4]를 [7]밑에 옮기려고 하는 경우: (nil, true)
      if let originStackIndex = tableauIndex(topCardOnTableauStack: cardNode.card),
         tableauStacks[targetStackIndex].canStack(cardNode.card) {
        // action: 이전 테이블 스택에서 새로운 테이블 스택으로 옮기고 이전 스택의 탑 카드를 지움
        stackCardOnTableau(cardNode, stackIndex: targetStackIndex) { [unowned self] in
          tableauStacks[originStackIndex].removeTopCard()
        }
        
        return
      }
      
      // case 1-3: 테이블 스택에서 2장 이상의 카드를 다른 스택으로 옮길 수 있는 경우
      if let originStackIndex = tableauStacksIndex(containingCard: cardNode.card),
         let movingCardChunks,
         tableauStacks[originStackIndex].faceUpCount > 1 {
        // print(tableauStacks[targetStackIndex].canStack(cardNode.card), cardNode.card)
        if tableauStacks[targetStackIndex].canStack(cardNode.card) {
          stackMultipleCardsOnTableau(
            movingCardChunks,
            firstCardNode: cardNode,
            stackIndex: targetStackIndex
          ) { [unowned self] in
            tableauStacks[originStackIndex].removeCards(from: movingCardChunks)
            self.movingCardChunks = nil
          }
        } else {
          backToOriginHandler()
        }
        
        return
      }
    }
    
    // case 2: 카드가 Foundation으로 옮겨졌을 때
    if let targetStackIndex = foundationStackIndex(containing: touchPoint),
       canPlaceCardToFoundationStack(cardNode.card, in: targetStackIndex) {
      // case 2-1: 스톡 파일(왼쪽 상단)에서 Foundation로 카드를 옮길 수 있음?
      if stockStacks.contains(cardNode.card) {
        // action: 스톡 파일의 카드를 파운데이션 스택으로 옮기고 해당 카드를 stocks에서 지움
        stackCardOnFoundation(cardNode, stackIndex: targetStackIndex) { [unowned self] in
          removeCardFromStockStacks(cardNode.card)
        }
        
        return
      }
      
      // case 2-2: 테이블 스택에서 파운데이션 스택, 옮길 수 있는 경우
      if let originStackIndex = tableauIndex(topCardOnTableauStack: cardNode.card) {
        // action: 이전 테이블 스택에서 새로운 파운데이션 스택으로 옮기고 이전 스택의 탑 카드를 지움
        stackCardOnFoundation(cardNode, stackIndex: targetStackIndex) { [unowned self] in
          tableauStacks[originStackIndex].removeTopCard()
        }
        
        return
      }
    }
    
    if isCardInStockStacks(cardNode.card) {
      return
    }
    
    backToOriginHandler()
    return
  }
  
  // 카드를 클릭하기 시작했을 때 액션
  func didClickCard(
    _ cardNode: CardNode,
    touchPoint: CGPoint,
    redrawHandler: VoidCallback,
    animSlideToWasteHandler: VoidCallback,
    dragStartHandler: VoidCallback,
    multipleDragStartHandler: VoidCallback
  ) {
    
    // case 1: 카드가 stock 에 있고, 뒷면일 때 => 앞면으로 전환하고 waste로 옮김
    if isCardInStockStacks(cardNode.card) && cardNode.displayMode == .back {
      cardNode.displayMode = .fullFront
      wasteIndex += 1
      cardNode.zPosition = CGFloat(wasteIndex)
      redrawHandler()
      animSlideToWasteHandler()
      return
    }
    
    // case 2: tableau에서 탑 카드가 뒷면일 때 => 앞면으로 전환
    if isTopCardOnTableauStack(cardNode.card),
       cardNode.displayMode == .back {
      cardNode.displayMode = .fullFront
      redrawHandler()
      dragStartHandler()
      return
    }
    
    // case 3: tableau에서 뒷면인데 top이 아닌 경우 이동하지 못하도록
    if !isTopCardOnTableauStack(cardNode.card) && cardNode.displayMode == .back {
      return
    }
    
    // case 4: 테이블에서 faceUpCount가 2 이상인 경우 (한 번에 옮길 수 있는 카드짝이 2개 이상)
    if let originStackIndex = tableauStacksIndex(containing: touchPoint),
       tableauStacks[originStackIndex].faceUpCount > 1,
       !isTopCardOnTableauStack(cardNode.card) {
      // RO: Read Only
      let tableauStackRO = tableauStacks[originStackIndex]
      let faceUpCount = tableauStackRO.faceUpCount
      let cardIndex = tableauStackRO.cardIndex(of: cardNode.card) ?? -99
      let distanceFromEnd = tableauStackRO.distanceFromEnd(of: cardNode.card) ?? -99
      
      if faceUpCount >= distanceFromEnd {
        // print("옮길 수 있음", faceUpCount, distanceFromEnd)
        let extractedCards = tableauStackRO.extractCards(from: cardIndex)
        movingCardChunks = extractedCards
        if let cardNodes = (cardNode.scene as? GameFieldScene)?.cardNodes(cardArray: Array(extractedCards[1...])),
           let scene = cardNode.scene {
          cardNodes.forEach { childNode in
            childNode.removeFromParent()
            cardNode.addChild(childNode)
            childNode.position = cardNode.convert(childNode.position, from: scene)
          }
        }
        
        dragStartHandler()
      }
      
      return
    }
    
    dragStartHandler()
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
  
  func stackMultipleCardsOnTableau(
    _ cards: [Card],
    firstCardNode: CardNode,
    stackIndex: Int,
    deleteCardHandler: VoidCallback? = nil
  ) {
    // 카드를 놓을 때 그 카드보다 zPos가 한 단계 더 높아야 함
    if let topCard = tableauStacks[stackIndex].topCard,
       let topCardNode = firstCardNode.scene?.childNode(withName: topCard.dataDescription) {
      firstCardNode.zPosition = topCardNode.zPosition + 1
    }
    
    tableauStacks[stackIndex].addCards(cards)
    deleteCardHandler?()
    
    tableauStacks[stackIndex].faceUpCount += cards.count
    if let position = tableauStackLocation(in: stackIndex, movingCardsCount: cards.count) {
      firstCardNode.position = .init(
        x: position.x,
        y: position.y
      )
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
