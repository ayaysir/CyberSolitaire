//
//  CardNodeDelegate.swift
//  CyberSolitaire
//
//  Created by 윤범태 on 5/26/25.
//

import Foundation

protocol CardNodeDelegate: AnyObject {
  func checkDropZone(
    _ cardNode: CardNode,
    touchPoint: CGPoint,
    backToOriginHandler: VoidCallback,
    successDropHandler: ((_ zPos: Int?) -> Void),
    cardGroupMoveCancelledHandler: VoidCallback
  )
  
  func didClickCard(
    _ cardNode: CardNode,
    touchPoint: CGPoint,
    redrawHandler: VoidCallback,
    animSlideToWasteHandler: VoidCallback,
    dragStartHandler: VoidCallback,
    multipleDragStartHandler: VoidCallback
  )
  
  func didMoveCard(
    _ cardNode: CardNode,
    touchPoint: CGPoint,
    multipleMoveHandler: VoidCallback
  )
  
  func didCardGroupMoveCancelled(
    _ cardNode: CardNode,
    touchPoint: CGPoint
  )
}
