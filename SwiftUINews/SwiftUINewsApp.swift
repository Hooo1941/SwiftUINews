//
//  SwiftUINewsApp.swift
//  SwiftUINews
//
//  Created by Hoo on 2021/6/2.
//

import SwiftUI

@main
struct SwiftUINewsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
