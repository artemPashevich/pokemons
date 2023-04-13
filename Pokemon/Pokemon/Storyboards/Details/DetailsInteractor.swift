//
//  DetailsInteractor.swift
//  Pokemon
//
//  Created by Артем Пашевич on 19.03.23.
//

import Foundation
import RealmSwift

protocol DetailsInteractorProtocol: AnyObject {
    func getDetailsInfo(for id: Int)
}

class DetailsInteractor: DetailsInteractorProtocol {
    
    weak var presenter: DetailsPresenterProtocol!
    var dataManager: PokemonDataManagerProtocol!
    
    func getDetailsInfo(for id: Int) {
        dataManager.getDetailsInfo(for: id) { [weak self] pokemon in
            self?.presenter.onDetailsInfoLoaded(pokemon: pokemon)
        }
    }
}
