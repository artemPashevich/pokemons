//
//  DataFetcherManager.swift
//  Pokemon
//
//  Created by Артем Пашевич on 25.04.23.
//

import SwiftyJSON
import UIKit
import RealmSwift

//final class DataFetcherManager {
//
//    static let shared = DataFetcherManager()
//
//    let realm = try! Realm()
//    let backendUrl = "https://pokeapi.co/api/v2/pokemon"
//
//    private let networkManager = NetworkManager(backendUrl: <#String#>)
//    private let databaseManager = DatabaseManager(realm: realm)
//    private let reachabilityManager = ReachabilityManager()
//
//    func getPokemonList(completion: @escaping (_ pokemons: [Pokemon]?, _ error: String?) -> Void) {
//        if reachabilityManager.isNetworkAvailable() {
//            networkManager.getPokemonList { [weak self] (pokemons, error) in
//                if let error = error {
//                    completion(nil, error)
//                } else if let pokemons = pokemons {
//                    self?.databaseManager.savePokemonList(pokemons)
//                    completion(pokemons, nil)
//                }
//            }
//        } else {
//            databaseManager.getPokemonList { (pokemons, error) in
//                completion(pokemons, error)
//            }
//        }
//    }
//
//    func getPokemonDetails(id: Int, completion: @escaping (JSON?, String?) -> Void) {
//        if reachabilityManager.isNetworkAvailable() {
//            networkManager.getPokemonDetails(id: id) { [weak self] (json, error) in
//                if let error = error {
//                    completion(nil, error)
//                } else if let json = json {
//                    self?.databaseManager.savePokemonDetails(id: id, json: json)
//                    completion(json, nil)
//                }
//            }
//        } else {
//            databaseManager.getPokemonDetails(id: id) { (json, error) in
//                completion(json, error)
//            }
//        }
//    }
//
//    func loadImageFromURL(url: URL, completion: @escaping (UIImage?) -> Void) {
//        networkManager.loadImageFromURL(url: url) { (image) in
//            completion(image)
//        }
//    }
//}

final class DataFetcherManager {
    
    let networkManager: NetworkProtocol
    let databaseManager: DatabaseManagerProtocol
    let reachabilityManager: ReachabilityProtocol
    
    init(networkManager: NetworkProtocol, databaseManager: DatabaseManagerProtocol, reachabilityManager: ReachabilityProtocol) {
        self.networkManager = networkManager
        self.databaseManager = databaseManager
        self.reachabilityManager = reachabilityManager
    }
    
    func getPokemonList(completion: @escaping (_ pokemons: [Pokemon]?, _ error: String?) -> Void) {
        if reachabilityManager.isNetworkAvailable {
            networkManager.getPokemonList { [weak self] (pokemons, error) in
                if let error = error {
                    completion(nil, error)
                } else if let pokemons = pokemons {
                    self?.databaseManager.savePokemons(pokemons)
                    completion(pokemons, nil)
                }
            }
        } else {
            let pokemons = databaseManager.getPokemons()
            if pokemons.isEmpty {
                completion(nil, "No cached data found")
            } else {
                completion(pokemons, nil)
            }
        }
    }
    
    func getPokemonDetails(id: Int, completion: @escaping (CachedPokemonDetails?, String?) -> Void) {
        if reachabilityManager.isNetworkAvailable {
            networkManager.getPokemonDetails(withId: id) { [weak self] (json, error) in
                if let error = error {
                    completion(nil, error)
                } else if let json = json {
                    self?.databaseManager.savePokemonDetails(id: id, json: json)
                    completion(json, nil)
                }
            }
        } else {
            if let json = databaseManager.getCachedPokemonDetails(withId: id)?.json{
                            completion(json, nil)
                        } else {
                            completion(nil, "No cached data found")
                        }
        }
    }
    
    func loadImageFromURL(url: URL, completion: @escaping (UIImage?) -> Void) {
        networkManager.loadImage(fromURL: url) { (image) in
            completion(image)
        }
    }
}
