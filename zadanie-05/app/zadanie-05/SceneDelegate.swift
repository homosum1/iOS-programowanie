//
//  SceneDelegate.swift
//  zadanie-05
//
//  Created by Alexander on 11/01/2025.
//

import Foundation
import UIKit
import OAuthSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        
        if url.host == "callback" {
            OAuthSwift.handle(url: url)
        }
        
        if url.host == "oauth-callback" {
            OAuthSwift.handle(url: url)
        }
    }

}
