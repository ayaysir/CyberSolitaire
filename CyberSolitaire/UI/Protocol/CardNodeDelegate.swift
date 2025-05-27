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
    returnHandler: VoidCallback
  )
  
  func didClickCard(
    _ cardNode: CardNode,
    touchPoint: CGPoint,
    redrawHandler: VoidCallback
  )
}
