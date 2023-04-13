//
//  Maneger.swift
//  Pokemon
//
//  Created by Артем Пашевич on 15.03.23.
//

import Alamofire
import RealmSwift
import SwiftyJSON
import UIKit

final class Manager {

    private init() {}

    static let shared = Manager()

    func getListName(completion: @escaping (_ pokemons: [Pokemon]?, _ error: String?) -> Void) {
        let cachedData = realm.objects(Pokemon.self)
        if !cachedData.isEmpty {
            completion(Array(cachedData), nil)
            return
        }
        
        AF.request(backendUrl)
            .responseData { [weak self] response in
                guard let self = self else {
                    return
                }
                switch response.result {
                case .success(let data):
                    do {
                        let response = try JSONDecoder().decode(PokemonResponse.self, from: data)
                        
                        try! self.realm.write {
                            self.realm.add(response.results)
                        }
                        
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
    
    func getDetailsInfo(id: Int, completion: @escaping (JSON?, String?) -> Void) {
        let cachedData = realm.object(ofType: CachedPokemonDetails.self, forPrimaryKey: id)
        if let cachedData = cachedData {
            let jsonData = try! JSONSerialization.jsonObject(with: cachedData.detailsData, options: []) as! [String: Any]
            completion(JSON(jsonData), nil)
            return
        }
        
        AF.request(backendUrl + "/\(id)")
            .responseData { [weak self] response in
                guard let self = self else {
                    return
                }
                switch response.result {
                case .success(let data):
                    do {
                        let response = try JSONDecoder().decode(JSON.self, from: data)
                        
                        let cachedDetails = CachedPokemonDetails()
                        cachedDetails.id = id
                        cachedDetails.detailsData = data
                        try! self.realm.write {
                            self.realm.add(cachedDetails)
                        }
                        
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
    
    func loadImageFromURL(url: URL, completion: @escaping (UIImage?) -> Void) {
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

    private let backendUrl = "https://pokeapi.co/api/v2/pokemon"
    private let realm = try! Realm()
}

