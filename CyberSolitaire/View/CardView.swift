struct CardView: View {
  let card: Card
  let width: CGFloat = 50
  
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 8)
        .fill(card.isFrontSide ? Color.white : Color.gray)
        .frame(width: width, height: width * 1.5)
        .shadow(radius: 5)
      if card.isFrontSide {
        Text("\(card.rankString) \(card.suit.symbol)")
          .font(.headline)
          .foregroundColor(card.suit.color == .red ? .red : .black)
      }
    }
  }
}