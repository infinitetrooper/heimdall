//
//  CameraView.swift
//  heimdall
//
//  Created by Akhil Varma on 27/12/23.
//

import Foundation
import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    @ObservedObject var cameraManager: CameraManager

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        cameraManager.setupCamera()
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

