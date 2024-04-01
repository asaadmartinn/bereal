//  AppDelegate.swift
//  BeReal Clone
//  Created by Amir on 2/29/24.

import UIKit
import ParseSwift


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ParseSwift.initialize(applicationId: "hS37k4DAlCjcr9cOq7Gint3cOgXAqEUwjCbNPga5",
                              clientKey: "TE9xQvx9TVoCurXeg4u15LH9zgYvDred9DFmIsJW",
                              serverURL: URL(string: "https://parseapi.back4app.com")!)
        
        return true
    }
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }


}

