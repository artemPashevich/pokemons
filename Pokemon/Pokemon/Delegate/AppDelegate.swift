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
//        deleteRealmFile()
        let config = Realm.Configuration(schemaVersion: 1)
        Realm.Configuration.defaultConfiguration = config
        do {
            let _ = try Realm()
        } catch {
            print("Error initializing Realm: \(error)")
        }
        return true
    }
    

    func deleteRealmFile() {
        let config = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        
        // Открываем Realm с указанной конфигурацией
        do {
            let realm = try Realm(configuration: config)
            
            // Удаляем файл Realm
            try realm.write {
                realm.deleteAll()
            }
            
            // Закрываем Realm
            realm.invalidate()
            
            // Получаем URL файла Realm и удаляем его
            if let realmURL = config.fileURL {
                do {
                    try FileManager.default.removeItem(at: realmURL)
                    print("Файл Realm успешно удален.")
                } catch {
                    print("Ошибка удаления файла Realm: \(error)")
                }
            }
        } catch {
            print("Ошибка открытия Realm: \(error)")
        }
    }


    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}

