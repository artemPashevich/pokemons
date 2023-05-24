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
    func getPokemonDetails(withId id: Int, completion: @escaping (JSON?, String?) -> Void)
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
                case .failure(_):
                    completion(nil, "network error")
                }
            }
    }

    func getPokemonDetails(withId id: Int, completion: @escaping (JSON?, String?) -> Void) {
        let url = backendUrl + "/\(id)"
        AF.request(url)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let response = try JSONDecoder().decode(JSON.self, from: data)
                        completion(response, nil)
                    } catch {
                        let error = "error decode json"
                        completion(nil, error)
                    }
                case .failure(_):
                    completion(nil, "network error")
                }
            }
    }

    func loadImage(fromURL url: URL, completion: @escaping (UIImage?) -> Void) {
        AF.download(url).responseData { response in
            switch response.result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    completion(image)
                } else {
                    completion(nil)
                }
            case .failure:
                completion(nil)
            }
        }
    }
}


