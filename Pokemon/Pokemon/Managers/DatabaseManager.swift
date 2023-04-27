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
    func getCachedPokemonDetails(withId id: Int) -> CachedPokemonDetails?
    func savePokemonDetails(_ details: CachedPokemonDetails)
}

final class DatabaseManager: DatabaseManagerProtocol {
    
    private let realm: Realm
    
    init(realm: Realm) {
        self.realm = realm
    }
    
    func savePokemons(_ pokemons: [Pokemon]) {
        try! realm.write {
            realm.add(pokemons, update: .all)
        }
    }
    
    func getPokemons() -> [Pokemon] {
        return Array(realm.objects(Pokemon.self))
    }
    
    func getCachedPokemonDetails(withId id: Int) -> CachedPokemonDetails? {
        return realm.object(ofType: CachedPokemonDetails.self, forPrimaryKey: id)
    }
    
    func savePokemonDetails(_ details: CachedPokemonDetails) {
        try! realm.write {
            realm.add(details, update: .all)
        }
    }
}


