//
//  ContentView.swift
//  ChooseThere
//
//  Created by Vinicius Carvalho Marques on 12/18/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
  var body: some View {
    RootView()
  }
}

#Preview {
  ContentView()
    .environment(AppRouter())
    .modelContainer(for: RestaurantModel.self, inMemory: true)
}


