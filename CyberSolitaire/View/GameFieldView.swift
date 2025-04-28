//
//  GameFieldView.swift
//  CyberSolitaire
//
//  Created by 윤범태 on 4/28/25.
//

import SwiftUI

struct GameFieldView: View {
  @State private var cards: [Card] = []
  @State private var deck: [Card] = []
  @State private var draggingCard: Card?
  @State private var dragOffset: CGSize = .zero
  @State private var dragStartingPoint: CGPoint = .zero
  
  var body: some View {
    ZStack(alignment: .topLeading) {
      Image(.cyberfunk1)
        .resizable()
        .scaledToFill()
        .frame(width: UIScreen.main.bounds.width)
        .ignoresSafeArea()
      
      if let dragging = draggingCard {
        CardView(card: dragging, displayMode: .fullFront)
          .offset(
            x: dragStartingPoint.x + dragOffset.width - 50,
            y: dragOffset.height
          )
          .zIndex(1000) // 무조건 최상단
      }
      
      VStack {
        // Top Cards ScrollView
        ScrollView(.horizontal, showsIndicators: true) {
          HStack(spacing: 16) {
            ForEach(cards.indices, id: \.self) { index in
              CardView(card: cards[index], displayMode: .fullFront)
                .zIndex(draggingCard == cards[index] ? 1 : 0)
                // .offset(draggingCard == cards[index] ? dragOffset : .zero)
                .opacity(draggingCard == cards[index] ? 0 : 1)
                .gesture(cardDragGesture(fromTop: index))
                .animation(.easeInOut(duration: 0.2), value: dragOffset)
            }
          }
          .padding(.leading, 16)
          .frame(height: 200)
          .padding(.vertical, 10)
          .background(Color.clear)
          .contentShape(Rectangle())
        }
        .allowsHitTesting(true)
        
        // Stack area
        HStack {
          VStack(alignment: .leading, spacing: -120) { // Negative spacing to overlap cards upward
            if deck.isEmpty {
              Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 80, height: 120)
                .cornerRadius(8)
                .overlay(Text("Empty").foregroundColor(.gray))
            } else {
              ForEach(deck.indices, id: \.self) { index in
                let isFrontOfDeck = index == deck.count - 1
                CardView(card: deck[index], displayMode: isFrontOfDeck ? .fullFront : .partialFront)
                  .frame(width: 80, height: 120)
                  // .scaleEffect(0.8)
                  .offset(y: CGFloat(index) * 20)
                  .zIndex(Double(index))
                  .gesture(deckCardDragGesture())
              }
            }
          }
          
          Spacer()
        }
        .padding(.leading, 24)
        .padding(.top, 16)
      }
    }
    .coordinateSpace(name: "screen")
    .onAppear(perform: setupCards)
  }
}

extension GameFieldView {
  private func cardDragGesture(fromTop index: Int) -> some Gesture {
    DragGesture(coordinateSpace: .global)
      .onChanged { value in
        // 감도 조절
        if draggingCard == nil && abs(value.translation.width) > 20 {
          draggingCard = cards[index]
        }
        if draggingCard == cards[index] {
          dragOffset = value.translation
          dragStartingPoint = value.startLocation
        }
      }
      .onEnded { _ in
        if let dragged = draggingCard {
          if let topDeckCard = deck.last, dragged.canStack(onto: topDeckCard) {
            deck.append(dragged)
            cards.removeAll { $0 == dragged }
          } else if deck.isEmpty {
            deck.append(dragged)
            cards.removeAll { $0 == dragged }
          }
        }
        draggingCard = nil
        dragOffset = .zero
      }
  }
  
  private func deckCardDragGesture() -> some Gesture {
    DragGesture()
      .onChanged { value in
        draggingCard = deck.last
        dragOffset = value.translation
      }
      .onEnded { _ in
        if let dragged = draggingCard {
          cards.append(dragged)
          deck.removeAll { $0 == dragged }
        }
        
        draggingCard = nil
        dragOffset = .zero
      }
  }
  
  private func setupCards() {
    var newCards: [Card] = []
    for suit in [Card.Suit.heart, .diamond, .club, .spade] {
      for rank in 1...13 {
        newCards.append(
          Card(
            suit: suit,
            rank: rank
          )
        )
      }
    }
    cards = newCards
      // .shuffled()
    deck = []
    draggingCard = nil
    dragOffset = .zero
  }
}

#Preview {
  GameFieldView()
}
