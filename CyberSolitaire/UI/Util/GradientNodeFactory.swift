//
//  GradientNodeFactory.swift
//  CyberSolitaire
//
//  Created by 윤범태 on 5/26/25.
//

import SpriteKit
import UIKit

enum GradientNodeFactory {
  /// 그라데이션 텍스처 생성
  static func makeLinearGradientTexture(
    size: CGSize,
    colors: [UIColor],
    angleDegree: CGFloat,
    locations: [NSNumber]? = nil
  ) -> SKTexture {
    let gradientLayer = CAGradientLayer()
    let (startPoint, endPoint) = gradientPoints(for: angleDegree)
    gradientLayer.frame = CGRect(origin: .zero, size: size)
    gradientLayer.colors = colors.map { $0.cgColor }
    gradientLayer.startPoint = startPoint
    gradientLayer.endPoint = endPoint
    gradientLayer.locations = locations

    UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
    gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    
    return SKTexture(image: image)
  }
  
  static func makeNoisyGradientNode(
    size: CGSize,
    cornerRadius: CGFloat,
    colors: [UIColor],
    angleDegree: CGFloat = 135,
    locations: [NSNumber]? = nil,
    noiseAlpha: CGFloat = 0.5,
    noiseBlendMode: SKBlendMode = .add,
    noiseTexture: UIImage = .dotnoiseLightGrey
  )  -> SKCropNode {
    // 노이즈 텍스쳐
    let gradientTexture = makeLinearGradientTexture(
      size: size,
      colors: colors,
      angleDegree: angleDegree,
      locations: locations
    )
    let gradientSprite = SKSpriteNode(texture: gradientTexture, size: size)
    let noiseTexture = SKTexture(image: noiseTexture)
    let noiseOverlay = SKSpriteNode(texture: noiseTexture, size: size)
    noiseOverlay.alpha = noiseAlpha
    noiseOverlay.blendMode = noiseBlendMode
    noiseOverlay.zPosition = 1
    
    let mask = SKShapeNode(rectOf: size, cornerRadius: 7)
    mask.fillColor = .white
    mask.strokeColor = .clear
    
    let crop = SKCropNode()
    crop.maskNode = mask
    crop.addChild(gradientSprite)
    crop.addChild(noiseOverlay)
    
    return crop
  }
  
  static func gradientPoints(for angle: CGFloat) -> (start: CGPoint, end: CGPoint) {
    let radians = angle * .pi / 180
    let dx = cos(radians)
    let dy = sin(radians)

    let start = CGPoint(x: 0.5 - dx / 2, y: 0.5 - dy / 2)
    let end = CGPoint(x: 0.5 + dx / 2, y: 0.5 + dy / 2)

    return (start, end)
  }

  /// 둥근 테두리를 포함한 그라데이션 배경 노드 생성
  static func makeRoundedGradientNode(
    size: CGSize,
    cornerRadius: CGFloat,
    colors: [UIColor],
    angleDegree: CGFloat = 135,
    locations: [NSNumber]? = nil
  ) -> SKCropNode {
    
    let texture = makeLinearGradientTexture(
      size: size,
      colors: colors,
      angleDegree: angleDegree,
      locations: locations
    )
 
    let sprite = SKSpriteNode(texture: texture, size: size)
 
    let mask = SKShapeNode(rectOf: size, cornerRadius: cornerRadius)
    mask.fillColor = .white
    mask.strokeColor = .clear
 
    let crop = SKCropNode()
    crop.addChild(sprite)
    crop.maskNode = mask
 
    return crop
  }
}
