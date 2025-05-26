//
//  Card.swift
//  CyberSolitaire
//
//  Created by 윤범태 on 4/28/25.
//

import Foundation

struct Card: Codable, Equatable {
  let suit: Suit
  let rank: Int
  // var isFrontSide = false
  var displayMode: DisplayMode = .fullFront
  
  /// 같은 색인지 확인
  func isSameColor(as other: Card) -> Bool {
    suit.color == other.suit.color
  }

  /// 편의 숫자:
  var value: Int {
    return suit.startNumber + rank
  }
  
  var rankString: String {
    switch rank {
    case 1: return "A"
    case 11: return "J"
    case 12: return "Q"
    case 13: return "K"
    default: return "\(rank)"
    }
  }
}

extension Card {
  /// 카드 종류: ♥ 하트 ♦ 다이아몬드(빨간색) / ♣ 클럽 ♠ 스페이드 (검은색)
  enum Suit: Int, Codable, CaseIterable {
    case heart = 0
    case diamond
    case club
    case spade
    
    var color: Card.Color {
      switch self {
      case .heart, .diamond:
          .red
      case .club, .spade:
          .black
      }
    }
    
    var symbol: String {
      switch self {
      case .heart: return "♥️"
      case .diamond: return "♦️"
      case .club: return "♣️"
      case .spade: return "♠️"
      }
    }
    
    var startNumber: Int {
      rawValue * 13
    }
  }
  
  enum Color {
    case red
    case black
  }
  
  enum DisplayMode: Codable {
    case fullFront
    case partialFront
    case back
  }
}
