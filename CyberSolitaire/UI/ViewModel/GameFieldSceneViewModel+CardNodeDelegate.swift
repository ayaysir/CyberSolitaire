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
 - ✔️ Stock Pile에서 카드 하나(또는 3개씩) 확인할 수 있게: waste 분리
 */

extension GameFieldSceneViewModel: CardNodeDelegate {
  
  // MARK: - Delegate methods
  
  // 카드가 이동했을 때 카드의 드랍 존(도착지) 액션
  func checkDropZone(
    _ cardNode: CardNode,
    touchPoint: CGPoint,
    backToOriginHandler: VoidCallback,
    successDropHandler: ((_ zPos: Int?) -> Void),
    cardGroupMoveCancelledHandler: VoidCallback
  ) {
    if cardNode.isGroupLeader {
      
    }
    // (cardNode.scene as? GameFieldScene)?.splitCardsFromChunks(cardNode)
    // case 1: 카드가 ㅇㅇㅇ 에서 tableau로 옮겨졌을 때
    if let targetStackIndex = tableauStacksIndex(containing: touchPoint) {
      // case 1-1: waste(왼쪽 상단)에서 테이블로 카드를 옮길 수 있음?
      if isTopCardInWaste(cardNode.card) {
        if tableauStacks[targetStackIndex].canStack(cardNode.card) {
          // action: 스톡 파일의 카드를 새로운 스택[stackIndex]으로 옮기고 마지막 stock을 지움
          stackCardOnTableau(cardNode, stackIndex: targetStackIndex) { [unowned self] in
            removeTopCardFromWasteStack()
          }
        } else {
          print("case 1-1: not possible")
          backToOriginHandler()
        }
        
        return
      }
      // case 1-2: 테이블 스택에서 테이블 스택, 옮길 수 있는 경우 (탑카드 1장)
      // print(isTopCardOnTableauStack(cardNode.card), tableauStacks[targetStackIndex].canStack(cardNode.card))
      // [6][5][4]를 [7]밑에 옮기려고 하는 경우: (nil, true)
      if let originStackIndex = tableauIndex(topCardOnTableauStack: cardNode.card),
         tableauStacks[originStackIndex].topCard == cardNode.card,
         tableauStacks[targetStackIndex].canStack(cardNode.card)
      {
        // action: 이전 테이블 스택에서 새로운 테이블 스택으로 옮기고 이전 스택의 탑 카드를 지움
        stackCardOnTableau(cardNode, stackIndex: targetStackIndex) { [unowned self] in
          tableauStacks[originStackIndex].removeTopCard()
        }
        
        return
      }
      
      print("isGroupLeader", cardNode.isGroupLeader)
      print("canStack:", tableauStacks[targetStackIndex].canStack(cardNode.card))
      
      // case 1-3: 테이블 스택에서 2장 이상의 카드를 다른 스택으로 옮길 수 있는 경우
      if cardNode.isGroupLeader, tableauStacks[targetStackIndex].canStack(cardNode.card) {
        let prevTopCard = tableauStacks[targetStackIndex].topCard
        
        print("originStackIndex:", tableauStacksIndex(containingCard: cardNode.card))
        if let originStackIndex = tableauStacksIndex(containingCard: cardNode.card) {
          print("mlt after originsi:", originStackIndex)
          
          guard let movingCardChunks = extractCards(cardNode.card, fromTableauStackIndex: originStackIndex) else {
            print("movingCardChunks extraction failed")
            return
          }
          
          stackMultipleCardsOnTableau(
            movingCardChunks,
            firstCardNode: cardNode,
            stackIndex: targetStackIndex) { [unowned self] in
              tableauStacks[originStackIndex].removeCards(from: movingCardChunks)
              if let prevTopCard,
                 let prevTopCardNode = (cardNode.scene as? GameFieldScene)?.childNode(withName: prevTopCard.dataDescription) as? CardNode {
                (cardNode.scene as? GameFieldScene)?.detachCardsFromChunks(cardNode, prevTopCardNode: prevTopCardNode)
              } else {
                (cardNode.scene as? GameFieldScene)?.detachCardsFromChunks(cardNode, prevTopCardNode: nil)
              }
            }
          print("1-3 completed")
          return
        }
      }
      
      // case 1-4: Foundation에서 tableau로 이동
      if foundationStackIndex(containingCard: cardNode.card) != nil,
         tableauStacks[targetStackIndex].canStack(cardNode.card) {
        stackCardOnTableau(cardNode, stackIndex: targetStackIndex) { [unowned self] in
          removeCardFromContainingFoundationStack(cardNode.card)
        }
        
        return
      }
      
      print("mlt after:", tableauStacks[targetStackIndex].cards.count, tableauStacks[targetStackIndex].cards)
    }
    
    // case 2: 카드가 ooo에서 Foundation으로 옮겨졌을 때
    print("case 2:", foundationStackIndex(containing: touchPoint), touchPoint, cardNode.parent?.className)
    if let targetStackIndex = foundationStackIndex(containing: touchPoint) {
      guard !cardNode.isGroupLeader else {
        print("옮길 수 없음")
        backToOriginHandler()
        (cardNode.scene as? GameFieldScene)?.detachCardsFromChunks(cardNode)
        return
      }
      
      print("case 2: targetStackIndex가 있음:", targetStackIndex)
      guard canPlaceCardToFoundationStack(cardNode.card, in: targetStackIndex) else {
        print("case 2: 카드를 놓을 수 없음")
        backToOriginHandler()
        return
      }
      // case 2-1: waste(왼쪽 상단)에서 Foundation로 카드를 옮길 수 있음?
      if isTopCardInWaste(cardNode.card) {
        // action: waste의 카드를 파운데이션 스택으로 옮기고 해당 카드를 stocks에서 지움
        print("case 2-1")
        stackCardOnFoundation(cardNode, stackIndex: targetStackIndex) { [unowned self] in
          removeTopCardFromWasteStack()
        }
        
        return
      }
      
      // case 2-2: 테이블 스택에서 파운데이션 스택, 탑 카드이며 옮길 수 있는 경우
      if let originStackIndex = tableauIndex(topCardOnTableauStack: cardNode.card) {
        print("case 2-2")

        // action: 이전 테이블 스택에서 새로운 파운데이션 스택으로 옮기고 이전 스택의 탑 카드를 지움
        stackCardOnFoundation(cardNode, stackIndex: targetStackIndex) { [unowned self] in
          tableauStacks[originStackIndex].removeTopCard()
        }
        
        return
      }
    }
    
    if isCardInStockStacks(cardNode.card) {
      print("Animation: send to waste")
      return
    }
    
    backToOriginHandler()
    (cardNode.scene as? GameFieldScene)?.detachCardsFromChunks(cardNode)
    
    return
  }
  
  // MARK: - 카드를 클릭하기 시작했을 때 액션
  func didClickCard(
    _ cardNode: CardNode,
    touchPoint: CGPoint,
    redrawHandler: VoidCallback,
    animSlideToWasteHandler: VoidCallback,
    dragStartHandler: VoidCallback,
    multipleDragStartHandler: VoidCallback
  ) {
    
    // case 1: 카드가 stock (top)에 있고, 뒷면일 때 => 앞면으로 전환하고 waste로 옮김
    if isTopCardInStock(cardNode.card) && cardNode.displayMode == .back {
      cardNode.displayMode = .fullFront
      wasteIndex += 1 // ??
      addCardFromStockToWaste()
      cardNode.zPosition = CGFloat(wasteIndex)
      
      redrawHandler()
      animSlideToWasteHandler()
      return
    }
    
    // case 2: tableau에서 탑 카드가 뒷면일 때 => 앞면으로 전환
    if let stackIndex = tableauIndex(topCardOnTableauStack: cardNode.card),
       cardNode.displayMode == .back {
      cardNode.displayMode = .fullFront
      tableauStacks[stackIndex].faceUpCount += 1
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
      
      guard let extractedCards = extractCards(cardNode.card, fromTableauStackIndex: originStackIndex) else {
        print("extractedCards가 없습니다.")
        return
      }
      
      if let scene = cardNode.scene as? GameFieldScene {
        scene.pasteCardsToBottom(cardNode, pasteCards: Array(extractedCards[1...]))
      }
      print("mlt bef:", tableauStacks[originStackIndex].cards.count, tableauStacks[originStackIndex].cards)
      cardNode.isGroupLeader = true
      dragStartHandler()
      return
    }
    
    // case 5: waste 움직일 수 있는 대상이 아님
    if isCardInWasteStacks(cardNode.card) && !isTopCardInWaste(cardNode.card) {
      print("IsCardInWastStacksButNotTop")
      return
    }
    
    dragStartHandler()
  }
  
  
  func didMoveCard(
    _ cardNode: CardNode,
    touchPoint: CGPoint,
    multipleMoveHandler: () -> Void
  ) {
    
  }
  
  func didCardGroupMoveCancelled(_ cardNode: CardNode, touchPoint: CGPoint) {
    print(#function)
    (cardNode.scene as? GameFieldScene)?.detachCardsFromChunks(cardNode)
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
    if let topCard = tableauStacks[stackIndex].topCard {
      if let topCardNode = cardNode.scene?.childNode(withName: topCard.dataDescription) {
        cardNode.zPosition = topCardNode.zPosition + 1
      } else {
        cardNode.zPosition = CGFloat((stackIndex + 1) * 100 + 50)
      }
    } else {
      cardNode.zPosition = CGFloat((stackIndex + 1) * 100)
    }
    
    if let position = tableauStackLocation(in: stackIndex) {
      cardNode.position = position
    }
    
    tableauStacks[stackIndex].addCards([card])
    // viewModel.tableauStacks[beforeStackIndex]
    deleteCardHandler?()
    
    tableauStacks[stackIndex].faceUpCount += 1
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
    } else {
      firstCardNode.zPosition = CGFloat((stackIndex + 1) * 100)
    }
    
    tableauStacks[stackIndex].addCards(cards)
    deleteCardHandler?()
    
    tableauStacks[stackIndex].faceUpCount += cards.count
    if let position = tableauStackLocation(in: stackIndex, movingCardsCount: cards.count + 1) {
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
    
    // 카드를 놓을 때 그 카드보다 zPos가 한 단계 더 높아야 함
    if let topCard = foundationStacks[stackIndex].cards.last,
       let topCardNode = cardNode.scene?.childNode(withName: topCard.dataDescription) {
      cardNode.zPosition = topCardNode.zPosition + 1
    } else {
      cardNode.zPosition = 10
    }
    
    if let postion = foundationStackLocation(in: stackIndex) {
      cardNode.position = postion
      placeCard(card, in: stackIndex)
      deleteCardHandler?()
    }
  }
}
