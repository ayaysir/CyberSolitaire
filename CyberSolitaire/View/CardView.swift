//
//  CardView.swift
//  CyberSolitaire
//
//  Created by 윤범태 on 4/28/25.
//

import SwiftUI

struct CardView: View {
  let card: Card
  let width: CGFloat = 50
  var displayMode: Card.DisplayMode
  
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 8)
        .fill(displayMode != .back ? Color.white : Color.gray)
        .shadow(radius: 5)
      switch displayMode {
      case .fullFront:
        Text("\(card.rankString) \(card.suit.symbol)")
          .font(.headline)
          .foregroundColor(card.suit.color == .red ? .red : .black)
      case .partialFront:
        VStack(spacing: 0) {
          Text("\(card.rankString) \(card.suit.symbol)")
            .font(.caption)
            .foregroundColor(card.suit.color == .red ? .red : .black)
            .padding(.top, 5)
          Spacer()
        }
      case .back:
        Text("")
      }
    }
    .frame(width: width, height: width * 1.5)
  }
}

#Preview {
  CardView(card: .init(suit: .club, rank: 1), displayMode: .partialFront)
}
