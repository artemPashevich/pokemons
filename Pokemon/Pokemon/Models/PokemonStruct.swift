//
//  Model.swift
//  Pokemon
//
//  Created by Артем Пашевич on 16.03.23.
//

import Foundation
import SwiftyJSON
import RealmSwift

@objcMembers class Pokemon: Object, Codable {
    dynamic var name: String?
    dynamic var url: String?
}

class CachedPokemonDetails: Object, Codable {
    @objc dynamic var id = 0
    @objc dynamic var detailsData = Data()

    override static func primaryKey() -> String? {
        return "id"
    }
}

struct PokemonResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [Pokemon]
}

struct PokemonDetails: Codable {
    let id: Int
    let name: String
    let imageUrl: URL
    let types: String
    let weight: String
    let height: String
    
    init(json: JSON) {
        id = json["id"].intValue
        name = json["name"].stringValue
        imageUrl = URL(string: json["sprites"]["back_default"].stringValue)!
        types = json["types"][0]["type"]["name"].stringValue
        weight = json["weight"].stringValue + " kg"
        height = json["height"].stringValue + " cm"
    }
}
