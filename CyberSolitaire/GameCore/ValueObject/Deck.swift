//
//  Deck.swift
//  CyberSolitaire
//
//  Created by 윤범태 on 5/26/25.
//

import Foundation

struct Deck: Codable {
  var index: Int = 1
  var cards: [Card] = []
  var dropZone: CGRect?
}
