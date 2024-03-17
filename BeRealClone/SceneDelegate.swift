//  SceneDelegate.swift
//  BeRealClone
//  Created by Amir on 2/29/24.

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    enum Constants {
        static let logInViewControllerIdentifier = "LogInViewController"
        static let navigationControllerIdentifier = "NavigationController"
        static let createPostViewControllerIdentifer = "CreatePostViewController"
        static let storyboardIdentifier = "Main"
    }


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }

        NotificationCenter.default.addObserver(forName: Notification.Name("login"), object: nil, queue: OperationQueue.main) { [weak self] _ in
            self?.login()
        }

        NotificationCenter.default.addObserver(forName: Notification.Name("logout"), object: nil, queue: OperationQueue.main) { [weak self] _ in
            self?.logout()
        }

        if User.current != nil {
            login()
        }
    }

    private func login() {
        let storyboard = UIStoryboard(name: Constants.storyboardIdentifier, bundle: nil)
        self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: Constants.navigationControllerIdentifier)
    }

    private func logout() {
        // Programmatically set the current displayed view controller.
        let storyboard = UIStoryboard(name: Constants.storyboardIdentifier, bundle: nil)
        self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: Constants.logInViewControllerIdentifier)
    }

}

