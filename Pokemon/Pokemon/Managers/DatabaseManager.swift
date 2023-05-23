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

protocol DatabaseManagerProtocol {
    func savePokemons(_ pokemons: [Pokemon])
    func getPokemons() -> [Pokemon]
    func getCachedPokemonDetails(withId id: Int) -> JSON?
    func savePokemonDetails(_ details: JSON)
    func saveImageData(_ data: Data, forKey key: String)
    func getCachedImageData(forKey key: String) -> Data?
}


final class DatabaseManager: DatabaseManagerProtocol {
    let realm = try! Realm()

    func savePokemons(_ pokemons: [Pokemon]) {
        try! realm.write {
            realm.add(pokemons, update: .all)
        }
    }

    func getPokemons() -> [Pokemon] {
        return Array(realm.objects(Pokemon.self))
    }

    func getCachedPokemonDetails(withId id: Int) -> JSON? {
        if let details = realm.object(ofType: CachedPokemonDetails.self, forPrimaryKey: id) {
            let dictionary: [String: Any] = [
                "id": details.id,
                "name": details.name,
                "imageUrlString": details.imageUrlString,
                "types": details.types,
                "weight": details.weight,
                "height": details.height
            ]
            let json = JSON(dictionary)
            return json
        }
        return nil
    }

    func savePokemonDetails(_ detailsJSON: JSON) {
        if let dictionary = detailsJSON.dictionaryObject {
            let details = CachedPokemonDetails(json: JSON(dictionary), online: true)
            try! realm.write {
                realm.create(CachedPokemonDetails.self, value: details, update: .all)
            }
        }
    }

    func saveImageData(_ data: Data, forKey key: String) {
        let cachedImage = CachedImageData()
        cachedImage.key = key
        cachedImage.data = data

        try! realm.write {
            realm.add(cachedImage, update: .all)
        }
    }

    func getCachedImageData(forKey key: String) -> Data? {
        return realm.object(ofType: CachedImageData.self, forPrimaryKey: key)?.data
    }
}
