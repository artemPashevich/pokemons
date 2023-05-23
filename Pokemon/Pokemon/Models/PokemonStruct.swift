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
    dynamic var name: String = ""
    dynamic var url: String = ""
    
    override static func primaryKey() -> String? {
        return "url"
    }
}

class CachedPokemonDetails: Object, Codable {
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var imageUrlString = ""
    @objc dynamic var types = ""
    @objc dynamic var weight = ""
    @objc dynamic var height = ""

    var imageUrl: URL? {
        return URL(string: imageUrlString)
    }

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(json: JSON, online: Bool) {
        self.init()
        self.id = json["id"].intValue
        self.name = json["name"].stringValue
        
        if online {
            self.types = json["types"][0]["type"]["name"].stringValue
            self.imageUrlString = json["sprites"]["back_default"].stringValue
        } else {
            self.types = json["types"].stringValue
            self.imageUrlString = json["imageUrlString"].stringValue
        }
        
        self.weight = json["weight"].stringValue
        self.height = json["height"].stringValue 
    }
}

class CachedImageData: Object {
    @objc dynamic var key = ""
    @objc dynamic var data: Data?
    
    override static func primaryKey() -> String? {
        return "key"
    }
}

struct PokemonResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [Pokemon]
}

