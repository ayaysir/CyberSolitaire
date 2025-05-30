//
//  StockAreaNode.swift
//  CyberSolitaire
//
//  Created by 윤범태 on 5/30/25.
//

import SpriteKit

/*
 TODO
 - stock 카드의 맨 위만 클릭 가능하게 하기
 - 마지막 영역을 클릭했을 때 stock 카드 상태 초기화
 - draw 1/3 대응
 */

class StockAreaNode: SKSpriteNode {
  var width: CGFloat = 50
  
  weak var delegate: StockAreaNodeDelegate?
  
  init(width: CGFloat = 50) {
    self.width = width
    let size = CGSize(width: width, height: width * 1.5)
    super.init(texture: nil, color: .clear, size: size)
    self.isUserInteractionEnabled = true // ✅ 터치 허용
    
    let neonBorder = SKShapeNode(rectOf: size, cornerRadius: 7)
    neonBorder.strokeColor = .systemMint
    neonBorder.lineWidth = 0.5
    neonBorder.glowWidth = 1
    // neonBorder.zPosition = 1
    neonBorder.fillColor = .red
    addChild(neonBorder)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension StockAreaNode {
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    print("StockAreaNode touchesBegan")
    delegate?.didClickArea(self)
  }
}
