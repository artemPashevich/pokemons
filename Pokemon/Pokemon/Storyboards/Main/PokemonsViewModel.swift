//
//  PokemonsModelView.swift
//  Pokemon
//
//  Created by Артем Пашевич on 23.05.23.
//

import Foundation

final class PokemonsViewModel {
    private let dataFetcherManager: DataFetcherManager
    private var pokemonsGroups: [Pokemon]?
    
    init(dataFetcherManager: DataFetcherManager) {
        self.dataFetcherManager = dataFetcherManager
    }
    
    var numberOfPokemons: Int {
        return pokemonsGroups?.count ?? 0
    }
    
    func getPokemonName(at index: Int) -> String? {
        return pokemonsGroups?[index].name
    }
    
    func fetchPokemons(completion: @escaping (String?) -> Void) {
        dataFetcherManager.getPokemonsFromAPI { [weak self] pokemons, error in
            if let error = error {
                completion(error)
            } else {
                self?.pokemonsGroups = pokemons
                completion(nil)
            }
        }
    }
}
