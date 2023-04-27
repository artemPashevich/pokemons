//
//  AppDelegate.swift
//  Pokemon
//
//  Created by Артем Пашевич on 15.03.23.
//

import UIKit
import RealmSwift
import SystemConfiguration

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let config = Realm.Configuration(schemaVersion: 1)
        Realm.Configuration.defaultConfiguration = config
        do {
            let _ = try Realm()
        } catch {
            print("Error initializing Realm: \(error)")
        }

        let internetConnectionAlert = checkInternetConnection()
        if internetConnectionAlert == nil {
            print("Подключение к интернету есть")
        } else {
            presentAlert(internetConnectionAlert!)
        }

        return true
    }

    func checkInternetConnection() -> UIAlertController? {
            var zeroAddress = sockaddr_in()
            zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
            zeroAddress.sin_family = sa_family_t(AF_INET)
            guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    SCNetworkReachabilityCreateWithAddress(nil, $0)
                }
            }) else {
                return nil
            }
            var flags: SCNetworkReachabilityFlags = []
            if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
                return nil
            }
            let isReachable = flags.contains(.reachable)
            let needsConnection = flags.contains(.connectionRequired)
            
            if !(isReachable && !needsConnection) {
                let alert = UIAlertController(title: "Ошибка", message: "Отсутствует подключение к интернету", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                return alert
            } else {
                return nil
            }
        }
        
        func presentAlert(_ alert: UIAlertController) {
            if let rootViewController = self.window?.rootViewController {
                rootViewController.present(alert, animated: true, completion: nil)
            }
        }
    

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}

