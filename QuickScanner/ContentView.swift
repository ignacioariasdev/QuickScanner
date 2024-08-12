//
//  ContentView.swift
//  QuickScanner
//
//  Created by Ignacio Arias on 2024-08-08.
//

import SwiftUI


struct ContentView: View {
    var body: some View {
        NavigationView {
            QSViewControllerRepresentable()
                .edgesIgnoringSafeArea(.all)
                .navigationBarHidden(false)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
