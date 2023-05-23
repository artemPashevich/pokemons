//
//  DataFetcherManager.swift
//  Pokemon
//
//  Created by Артем Пашевич on 25.04.23.
//

import SwiftyJSON
import UIKit
import RealmSwift

final class DataFetcherManager {
    
    let networkManager: NetworkProtocol
    let databaseManager: DatabaseManagerProtocol
    let reachabilityManager: ReachabilityProtocol
    
    init() {
        networkManager = NetworkManager(backendUrl: "https://pokeapi.co/api/v2/pokemon") // разбил только на id
        databaseManager = DatabaseManager()
        reachabilityManager = ReachabilityManager()
    }
    
    func getPokemonsFromAPI(completion: @escaping (_ pokemons: [Pokemon]?, _ error: String?) -> Void) {
        if reachabilityManager.isNetworkAvailable {
            networkManager.getPokemonList { [weak self] pokemons, error in
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
                completion(nil, "no internet connection")
            } else {
                completion(pokemons, nil)
            }
        }
    }
    
    func getPokemonDetails(id: Int, completion: @escaping (JSON?, String?, Bool?) -> Void) {
        if reachabilityManager.isNetworkAvailable {
            networkManager.getPokemonDetails(withId: id) { [weak self] (json, error) in
                if let error = error {
                    completion(nil, error, nil)
                } else if let json = json {
                    self?.databaseManager.savePokemonDetails(json)
                    completion(json, nil, true)
                }
            }
        } else {
            if let cachedPokemonDetails = databaseManager.getCachedPokemonDetails(withId: id) {
                completion(cachedPokemonDetails, nil, false)
            } else {
                completion(nil, "no internet connection", nil)
            }
        }
    }
    
    func loadImageFromURL(urlString: String?, completion: @escaping (UIImage?, String?) -> Void) {
        guard let urlString = urlString  else { return }
        print("URL: " + urlString)
        if reachabilityManager.isNetworkAvailable {
            guard let url = URL(string: urlString) else { return }
            networkManager.loadImage(fromURL: url) { [weak self] image in
                if let image = image {
                    if let imageData = image.pngData() {
                        self?.databaseManager.saveImageData(imageData, forKey: urlString)
                        completion(image, nil)
                    }
                } else {
                    completion(UIImage(named: "default"), "Failed to load image")
                }
            }
        } else {
            if let imageData = databaseManager.getCachedImageData(forKey: urlString),
               let image = UIImage(data: imageData) {
                completion(image, nil)
            } else {
                completion(UIImage(named: "default"), "Invalid image URL")
            }
        }
    }
}
