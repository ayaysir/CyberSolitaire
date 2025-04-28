//
//  CyberSolitaireApp.swift
//  CyberSolitaire
//
//  Created by 윤범태 on 4/28/25.
//

import SwiftUI

@main
struct CyberSolitaireApp: App {
  let persistenceController = PersistenceController.shared
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}
