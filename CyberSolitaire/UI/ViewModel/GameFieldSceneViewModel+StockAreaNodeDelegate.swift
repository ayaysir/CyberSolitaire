//
//  GameFieldSceneViewModel+StockAreaNodeDelegate.swift
//  CyberSolitaire
//
//  Created by 윤범태 on 5/30/25.
//

import Foundation

extension GameFieldSceneViewModel: StockAreaNodeDelegate {
  func didClickArea(_ node: StockAreaNode) {
    guard let scene = node.scene as? GameFieldScene else {
      return
    }
    print("stocks:", stockStacks.count)
    scene.removeWasteCardNodes()
    setStockFromRemainWaste()
    scene.setStockCardNodes()
  }
}
