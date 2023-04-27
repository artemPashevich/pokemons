//
//  NetworkManager.swift
//  Pokemon
//
//  Created by Артем Пашевич on 20.04.23.
//

import Foundation
import Alamofire
import SwiftyJSON
import UIKit

protocol NetworkProtocol {
    func getPokemonList(completion: @escaping (_ pokemons: [Pokemon]?, _ error: String?) -> Void)
    func getPokemonDetails(withId id: Int, completion: @escaping (CachedPokemonDetails?, String?) -> Void)
    func loadImage(fromURL url: URL, completion: @escaping (UIImage?) -> Void)
}

class NetworkManager: NetworkProtocol {

    private let backendUrl: String
    
    init(backendUrl: String) {
        self.backendUrl = backendUrl
    }

    func getPokemonList(completion: @escaping (_ pokemons: [Pokemon]?, _ error: String?) -> Void) {
        let url = backendUrl
        AF.request(url)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let response = try JSONDecoder().decode(PokemonResponse.self, from: data)
                        completion(response.results, nil)
                    } catch {
                        let error = "error decode json"
                        completion(nil, error)
                    }
                case .failure(let error):
                    completion(nil, error.errorDescription)
                }
            }
    }

    func getPokemonDetails(withId id: Int, completion: @escaping (CachedPokemonDetails?, String?) -> Void) {
        let url = backendUrl + "/\(id)"
        AF.request(url)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let response = try JSONDecoder().decode(CachedPokemonDetails.self, from: data)
                        completion(response, nil)
                    } catch {
                        let error = "error decode json"
                        completion(nil, error)
                    }
                case .failure(let error):
                    completion(nil, error.errorDescription)
                }
            }
    }

    func loadImage(fromURL url: URL, completion: @escaping (UIImage?) -> Void) {
        let request = URLRequest(url: url)
        let cache = URLCache.shared
        if let cachedResponse = cache.cachedResponse(for: request) {
            if let image = UIImage(data: cachedResponse.data) {
                completion(image)
                return
            }
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let data = data, let response = response else {
                completion(nil)
                return
            }
            cache.storeCachedResponse(CachedURLResponse(response: response, data: data), for: request)
            if let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
}


