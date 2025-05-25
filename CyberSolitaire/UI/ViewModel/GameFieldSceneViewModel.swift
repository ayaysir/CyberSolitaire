//
//  GameFieldSceneViewModel.swift
//  CyberSolitaire
//
//  Created by 윤범태 on 5/26/25.
//

import Foundation

final class GameFieldSceneViewModel: ObservableObject {
  @Published var cards: [Card] = []
  @Published var deck: [Card] = []
}
