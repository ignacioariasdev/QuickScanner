//
//  QSViewControllerRepresentable.swift
//  QuickScanner
//
//  Created by Ignacio Arias on 2024-08-08.
//

import Foundation
import SwiftUI

struct QSViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> QSViewController {
        return QSViewController()
    }
    
    func updateUIViewController(_ uiViewController: QSViewController, context: Context) {
        // Update the view controller if needed
    }
}
